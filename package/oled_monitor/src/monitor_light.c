#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <ncurses.h>
#include <time.h>
#include <locale.h>
#include <sys/types.h>
#include <ifaddrs.h>
#include <netinet/in.h>
#include <arpa/inet.h>

// --- Configuration ---
#define NUM_CORES 4
#define PATH_TEMP "/sys/class/thermal/thermal_zone0/temp"

// Noms des interfaces à surveiller
#define IFACE_ETH  "eth0"
#define IFACE_WIFI "wlan0"

const char *MOIS_FR[] = {"Jan", "Fev", "Mar", "Avr", "Mai", "Juin", "Juil", "Aou", "Sep", "Oct", "Nov", "Dec"};

// --- Structures ---

typedef struct {
    unsigned long long prev_active;
    unsigned long long prev_iowait;
    unsigned long long prev_idle; // Gardé pour la structure
    unsigned long long prev_total;
} CpuData;

typedef struct {
    char name[16];
    char ip[16];
    int active;
} NetData;

CpuData cores[NUM_CORES];
NetData net_data[2]; // Index 0 = ETH, Index 1 = WIFI

// --- Helpers ---
// --- Helpers Affichage Logo ---

void show_splash_screen(const char *image_path, int fb_id) {
    char fb_path[32];
    snprintf(fb_path, sizeof(fb_path), "/dev/fb%d", fb_id);

    FILE *src = fopen(image_path, "rb");
    if (!src) {
        fprintf(stderr, "Erreur: Impossible d'ouvrir l'image %s\n", image_path);
        return;
    }

    FILE *dst = fopen(fb_path, "wb");
    if (!dst) {
        fprintf(stderr, "Erreur: Impossible d'ouvrir le framebuffer %s\n", fb_path);
        fclose(src);
        return;
    }

    // Copie par buffer (efficace)
    char buffer[4096];
    size_t bytes;
    while ((bytes = fread(buffer, 1, sizeof(buffer), src)) > 0) {
        fwrite(buffer, 1, bytes, dst);
    }

    fclose(src);
    fclose(dst);

    // Pause de 5 secondes
    sleep(5);
}

void init_data() {
    memset(cores, 0, sizeof(cores));
    memset(net_data, 0, sizeof(net_data));
}

void print_centered(int y, const char *text, int attrs) {
    int len = strlen(text);
    int pad = (16 - len) / 2;
    if (pad < 0) pad = 0;
    move(y, 0); clrtoeol();
    attron(attrs);
    mvprintw(y, pad, "%s", text);
    attroff(attrs);
}

void print_right(int y, const char *text, int attrs) {
    int len = strlen(text);
    int pad = 16 - len;
    if (pad < 0) pad = 0;
    move(y, 0); clrtoeol();
    attron(attrs);
    mvprintw(y, pad, "%s", text);
    attroff(attrs);
}

int get_cpu_temp() {
    FILE *f = fopen(PATH_TEMP, "r");
    if (!f) return 0;
    char buf[16];
    if (fgets(buf, sizeof(buf), f)) {
        int raw = atoi(buf);
        fclose(f);
        return raw / 1000;
    }
    fclose(f);
    return 0;
}

// --- Logique CPU ---

void update_cpu_stats(float *pct_active, float *pct_iowait) {
    FILE *fp = fopen("/proc/stat", "r");
    if (!fp) return;

    char buf[1024];
    int core_idx = 0;

    while (fgets(buf, sizeof(buf), fp) && core_idx < NUM_CORES) {
        if (strncmp(buf, "cpu", 3) == 0 && buf[3] >= '0' && buf[3] <= '9') {
            unsigned long long user, nice, system, idle, iowait, irq, softirq, steal;
            sscanf(buf, "%*s %llu %llu %llu %llu %llu %llu %llu %llu",
                   &user, &nice, &system, &idle, &iowait, &irq, &softirq, &steal);

            CpuData *c = &cores[core_idx];
            unsigned long long current_active = user + nice + system + irq + softirq + steal;
            unsigned long long current_total = current_active + idle + iowait;

            unsigned long long total_d = current_total - c->prev_total;
            unsigned long long active_d = current_active - c->prev_active;
            unsigned long long iowait_d = iowait - c->prev_iowait;

            if (total_d == 0) {
                pct_active[core_idx] = 0.0;
                pct_iowait[core_idx] = 0.0;
            } else {
                pct_active[core_idx] = ((float)active_d / total_d) * 100.0;
                pct_iowait[core_idx] = ((float)iowait_d / total_d) * 100.0;
            }

            if (pct_active[core_idx] > 100.0) pct_active[core_idx] = 100.0;
            if (pct_iowait[core_idx] > 100.0) pct_iowait[core_idx] = 100.0;

            c->prev_active = current_active;
            c->prev_iowait = iowait;
            c->prev_total = current_total;
            core_idx++;
        }
    }
    fclose(fp);
}

// --- Logique Réseau (getifaddrs standard) ---

void update_network_simple() {
    struct ifaddrs *ifaddr, *ifa;

    // Reset
    net_data[0].active = 0;
    net_data[1].active = 0;

    if (getifaddrs(&ifaddr) == -1) return;

    for (ifa = ifaddr; ifa != NULL; ifa = ifa->ifa_next) {
        if (ifa->ifa_addr == NULL) continue;

        // On ne cherche que de l'IPv4 (AF_INET)
        if (ifa->ifa_addr->sa_family == AF_INET) {

            int slot = -1;
            if (strcmp(ifa->ifa_name, IFACE_ETH) == 0) slot = 0;
            else if (strcmp(ifa->ifa_name, IFACE_WIFI) == 0) slot = 1;

            if (slot != -1) {
                struct sockaddr_in *pAddr = (struct sockaddr_in *)ifa->ifa_addr;

                strncpy(net_data[slot].name, ifa->ifa_name, 15);
                // Conversion binaire -> texte
                inet_ntop(AF_INET, &(pAddr->sin_addr), net_data[slot].ip, 16);
                net_data[slot].active = 1;
            }
        }
    }
    freeifaddrs(ifaddr);
}

// --- Main ---

int main(int argc, char *argv[]) {
      // 1. GESTION DU LOGO DE DEMARRAGE
    // Si on a 2 arguments supplémentaires (path + fb_id)
    if (argc == 3) {
        const char *img_path = argv[1];
        int fb_id = atoi(argv[2]);

        // Affiche l'image brute et attend 5s
        show_splash_screen(img_path, fb_id);
    }
    // Note: Utilise /dev/tty3 si tu as suivi le conseil pour éviter le conflit GDM
    // Sinon remets /dev/tty1
    int tty_fd = open("/dev/tty1", O_WRONLY); // <-- NOUVELLE LIGNE (Ok pour group tty)
    if (tty_fd >= 0) {
      dup2(tty_fd, STDOUT_FILENO);
      // On peut fermer le fd original car dup2 l'a dupliqué sur 1
      // close(tty_fd);
    } else {
      // Optionnel : Afficher l'erreur sur stderr pour debugger si ça échoue encore
      fprintf(stderr, "Impossible d'ouvrir tty1, affichage dans le terminal courant.\n");
    }
    setlocale(LC_ALL, "");

    initscr();
    cbreak();
    noecho();
    curs_set(0);

    init_data();

    float cpu_usage[NUM_CORES];
    float cpu_iowait[NUM_CORES];
    char footer_str[32];
    char temp_str[32];
    int tick = 0;

    while (1) {
        // Temps & Footer
        time_t now = time(NULL);
        struct tm *t = localtime(&now);
        snprintf(footer_str, sizeof(footer_str), "%02d %s - %02d:%02d",
                 t->tm_mday, MOIS_FR[t->tm_mon], t->tm_hour, t->tm_min);

        // Température
        int temp = get_cpu_temp();
        snprintf(temp_str, sizeof(temp_str), "%d C", temp);

        // Header Jaune
        print_centered(0, "-=== 4kopen ===-", A_BOLD);
        print_right(1, temp_str, A_BOLD);

        // --- Logique Alternée (Cycle 10s) ---
        // 0 à 7 (8s) : CPU
        // 8 à 9 (2s) : Réseau

        if ((tick % 16) < 14) {
            // --- MODE CPU ---
            update_cpu_stats(cpu_usage, cpu_iowait);

            for(int i=0; i<NUM_CORES; i++) {
                char bar[16];
                memset(bar, ' ', 10);
                bar[10] = '\0';

                int num_active = (int)(cpu_usage[i] / 10.0 + 0.5);
                int num_io = (int)(cpu_iowait[i] / 10.0 + 0.5);

                if (num_active > 10) num_active = 10;
                if (num_io > 10) num_io = 10;
                if (num_active + num_io > 10) num_io = 10 - num_active;

                for(int k=0; k<10; k++) {
                    if (k < num_active) bar[k] = '=';
                    else if (k < num_active + num_io) bar[k] = '.';
                }
                move(2 + i, 0);
                printw("%d [%s]", i+1, bar);
            }
        }
        else {
            // --- MODE RESEAU ---
            update_network_simple();

            int current_row = 2;
            int found = 0;

            // Affichage ETH
            if (net_data[0].active) {
                move(current_row, 0); clrtoeol();
                print_centered(current_row, net_data[0].name, A_BOLD); // "eth0"
                current_row++;
                move(current_row, 0); clrtoeol();
                print_centered(current_row, net_data[0].ip, A_NORMAL); // IP
                current_row++;
                found = 1;
            }

            // Affichage WIFI
            if (net_data[1].active && current_row < 6) {
                move(current_row, 0); clrtoeol();
                print_centered(current_row, net_data[1].name, A_BOLD); // "wlan0"
                current_row++;
                move(current_row, 0); clrtoeol();
                print_centered(current_row, net_data[1].ip, A_NORMAL); // IP
                current_row++;
                found = 1;
            }

            if (!found) {
                move(2, 0); clrtoeol();
                print_centered(3, "No Network", A_DIM);
                move(4, 0); clrtoeol();
                move(5, 0); clrtoeol();
            } else {
                // Nettoyage lignes restantes
                while (current_row < 6) {
                    move(current_row, 0); clrtoeol();
                    current_row++;
                }
            }
        }

        move(6, 0); clrtoeol();

        // Footer
        move(7, 0); clrtoeol();
        attron(A_DIM);
        print_centered(7, footer_str, A_DIM);
        attroff(A_DIM);

        refresh();
        tick++;
        sleep(1);
    }

    endwin();
    return 0;
}

