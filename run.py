import shutil
import subprocess
from pathlib import Path

# ============================================================
# run.py — HealthAI : lancement et déploiement du projet
# ============================================================

REPOS = [
    "healthAI-backend-API",
    "healthAI-backend-ETL",
    "healthAI-backend-model-IA",
    "healthAI-config",
    "healthAI-database",
    "healthAI-frontend",
    "healthAI-service-nutrition",
    "healthAI-service-exercices",
    "healthAI-application-database",
]

# Fichiers à dupliquer depuis healthAI-config vers le dossier courant
FILES_TO_COPY = [
    "docker-compose.yml",
    "docker-compose_offline.yml",
    "docker-compose_perf.yml",
    "README.md",
]

# Couleurs ANSI
GREEN = "\033[0;32m"
RED = "\033[0;31m"
YELLOW = "\033[1;33m"
CYAN = "\033[0;36m"
BOLD = "\033[1m"
NC = "\033[0m"

# Chemins
BASE_DIR = Path(__file__).parent.resolve()          # dossier où se trouve run.py
CONFIG_DIR = BASE_DIR / "healthAI-config"           # sous-dossier healthAI-config

# ── Helpers ──────────────────────────────────────────────────────────────────

def header(title: str):
    print(f"\n{CYAN}{'═' * 48}{NC}")
    print(f"{CYAN} {title}{NC}")
    print(f"{CYAN}{'═' * 48}{NC}\n")

def ok(msg):
    print(f" {GREEN}✔ {msg}{NC}")

def err(msg):
    print(f" {RED}✘ {msg}{NC}")

def warn(msg):
    print(f" {YELLOW}⚠ {msg}{NC}")

def info(msg):
    print(f" {CYAN}➜ {msg}{NC}")

def copy_files_to_base():
    """Copie les docker-compose et le README depuis healthAI-config/ vers le dossier courant."""
    header("Synchronisation des fichiers de configuration")

    if not CONFIG_DIR.exists():
        err(f"Dossier healthAI-config introuvable : {CONFIG_DIR}")
        return

    for fname in FILES_TO_COPY:
        src = CONFIG_DIR / fname
        dst = BASE_DIR / fname

        if not src.exists():
            warn(f"{fname} introuvable dans healthAI-config — ignoré")
            continue

        shutil.copy2(src, dst)
        ok(f"{fname} → {BASE_DIR}")

def git_pull(repo_path: Path):
    result = subprocess.run(
        ["git", "pull"],
        cwd=repo_path,
        capture_output=True,
        text=True
    )
    output = result.stdout.strip() or result.stderr.strip()
    return result.returncode == 0, output

def run_docker_compose(compose_file: str, label: str):
    """Lance docker compose -f <fichier> up --build -d depuis le dossier courant."""
    header(f"Démarrage Docker Compose — {label}")
    compose_path = BASE_DIR / compose_file

    if not compose_path.exists():
        err(f"{compose_file} introuvable dans {BASE_DIR}")
        return

    env_path = BASE_DIR / ".env"
    if not env_path.exists():
        warn(f"Fichier .env introuvable dans {BASE_DIR}")
        warn("Docker Compose risque de démarrer avec des variables vides.")

    cmd = ["docker", "compose", "-f", str(compose_path), "up", "--build", "-d"]
    info(f"Commande : {' '.join(cmd)}")
    print()

    result = subprocess.run(cmd, cwd=BASE_DIR)
    print()

    if result.returncode == 0:
        ok("Stack démarrée avec succès.")
        print(f"\n {BOLD}Accès aux services :{NC}")
        print(" Frontend   → http://localhost:4200")
        print(" API        → http://localhost:5000")
        print(" ETL        → http://localhost:8000")
        print(" Nutrition  → http://localhost:8001")
        print(" Exercices  → http://localhost:8002")
        print(" Grafana    → http://localhost:3000")
        print(" MinIO      → http://localhost:9001")
    else:
        err("Échec du démarrage. Consultez les logs : docker compose logs -f")

# ── Menu ─────────────────────────────────────────────────────────────────────

def show_menu():
    print(f"\n{BOLD}{'═' * 48}")
    print(" HealthAI — Gestionnaire de déploiement")
    print(f"{'═' * 48}{NC}\n")
    print(f" {YELLOW}1{NC} Mettre à jour les dépôts {CYAN}(git pull){NC}")
    print(f" {YELLOW}2{NC} Lancer la stack normale {CYAN}(docker-compose.yml){NC}")
    print(f" {YELLOW}3{NC} Lancer le mode offline {CYAN}(docker-compose_offline.yml){NC}")
    print(f" {YELLOW}4{NC} Lancer le mode perf {CYAN}(docker-compose_perf.yml){NC}")
    print(f" {YELLOW}0{NC} Quitter\n")

def option_1_git_pull():
    header("Mise à jour des dépôts Git")
    success = failed = skipped = 0

    for repo in REPOS:
        repo_path = BASE_DIR / repo
        print(f"{YELLOW}➜ {repo}{NC}")

        if not repo_path.exists():
            err(f"Dossier introuvable : {repo_path}")
            skipped += 1
            continue

        if not (repo_path / ".git").exists():
            warn("Pas un dépôt git")
            skipped += 1
            continue

        pulled, output = git_pull(repo_path)
        if pulled:
            ok(output)
            success += 1
        else:
            err(output)
            failed += 1
        print()

    print(f"{CYAN}{'═' * 48}{NC}")
    print(f" {GREEN}✔ Succès : {success}{NC}")
    print(f" {RED}✘ Échecs : {failed}{NC}")
    print(f" {YELLOW}⚠ Ignorés : {skipped}{NC}")
    print(f"{CYAN}{'═' * 48}{NC}")

    copy_files_to_base()

def option_2_docker_normal():
    copy_files_to_base()
    run_docker_compose("docker-compose.yml", "Standard")

def option_3_docker_offline():
    copy_files_to_base()
    run_docker_compose("docker-compose_offline.yml", "Offline")

def option_4_docker_perf():
    copy_files_to_base()
    run_docker_compose("docker-compose_perf.yml", "Performance")

# ── Point d'entrée ───────────────────────────────────────────────────────────

def main():
    show_menu()
    choice = input(f" {BOLD}Votre choix :{NC} ").strip()

    if choice == "1":
        option_1_git_pull()
    elif choice == "2":
        option_2_docker_normal()
    elif choice == "3":
        option_3_docker_offline()
    elif choice == "4":
        option_4_docker_perf()
    elif choice == "0":
        print(f"\n {CYAN}À bientôt !{NC}\n")
    else:
        err(f"Choix invalide : « {choice} »")
        main()

if __name__ == "__main__":
    main()