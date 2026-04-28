import os
import shutil
import subprocess
from pathlib import Path

# ============================================
#  Git Pull - Tous les projets healthAI
# ============================================

REPOS = [
    "healthAI-backend-API",
    "healthAI-backend-ETL",
    "healthAI-backend-model-IA",
    "healthAI-config",
    "healthAI-database",
    "healthAI-frontend",
]

# Couleurs ANSI
GREEN  = "\033[0;32m"
RED    = "\033[0;31m"
YELLOW = "\033[1;33m"
CYAN   = "\033[0;36m"
NC     = "\033[0m"

BASE_DIR = Path(__file__).parent.parent.resolve()

def print_header():
    print(f"{CYAN}{'='*42}{NC}")
    print(f"{CYAN}   Git Pull - Projets healthAI{NC}")
    print(f"{CYAN}{'='*42}{NC}\n")

def print_summary(success, failed, skipped):
    print(f"{CYAN}{'='*42}{NC}")
    print(f"  {GREEN}✔  Succès  : {success}{NC}")
    print(f"  {RED}✘  Échecs  : {failed}{NC}")
    print(f"  {YELLOW}⚠  Ignorés : {skipped}{NC}")
    print(f"{CYAN}{'='*42}{NC}")

def git_pull(repo_path: Path) -> tuple[bool, str]:
    result = subprocess.run(
        ["git", "pull"],
        cwd=repo_path,
        capture_output=True,
        text=True
    )
    output = result.stdout.strip() or result.stderr.strip()
    return result.returncode == 0, output

def deploy_docker_compose():
    src = Path(__file__).parent / "docker-compose.yml"
    dst = BASE_DIR / "docker-compose.yml"

    print(f"{CYAN}{'='*42}{NC}")
    print(f"{CYAN}   Docker Compose{NC}")
    print(f"{CYAN}{'='*42}{NC}")

    if not src.exists():
        print(f"   {RED}✘  docker-compose.yml introuvable dans healthAI-config{NC}\n")
        return

    if dst.exists():
        dst.unlink()
        print(f"   {YELLOW}⚠  Ancien docker-compose.yml supprimé à la racine{NC}")

    shutil.copy2(src, dst)
    print(f"   {GREEN}✔  docker-compose.yml copié à la racine{NC}\n")

def main():
    print_header()

    success = failed = skipped = 0

    for repo in REPOS:
        repo_path = BASE_DIR / repo
        print(f"{YELLOW}➜  {repo}{NC}")

        if not repo_path.exists():
            print(f"   {RED}✘  Dossier introuvable : {repo_path}{NC}\n")
            skipped += 1
            continue

        if not (repo_path / ".git").exists():
            print(f"   {RED}✘  Pas un dépôt git{NC}\n")
            skipped += 1
            continue

        ok, output = git_pull(repo_path)

        if ok:
            print(f"   {GREEN}✔  {output}{NC}\n")
            success += 1
        else:
            print(f"   {RED}✘  {output}{NC}\n")
            failed += 1

    print_summary(success, failed, skipped)
    deploy_docker_compose()

if __name__ == "__main__":
    main()
