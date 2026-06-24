# godot_discovery.py
from pathlib import Path

def find_godot_project_root(start_path: Path = Path('/home/marcin/projects/ai_crew')) -> Path:
    """
    Szuka rekursywnie pliku 'project.godot' zaczynając od katalogu nadrzędnego
    podanej ścieżki startowej. Zwraca absolutną ścieżkę do katalogu projektu.
    """
    # Przechodzimy do katalogu nadrzędnego (np. /home/marcin/projects)
    parent_dir = start_path.parent
    
    # Szukamy rekursywnie pliku project.godot
    for file_path in parent_dir.rglob('project.godot'):
        if file_path.exists() and file_path.is_file():
            project_root = file_path.parent.resolve()
            print(f"DIAGNOZA: Znaleziono korzeń projektu Godot: {project_root}")
            return project_root
            
    # Rzucamy błąd, jeśli plik nie istnieje w całym drzewie
    raise FileNotFoundError("Nie znaleziono pliku project.godot w drzewie katalogów.")

if __name__ == "__main__":
    try:
        find_godot_project_root()
    except FileNotFoundError as e:
        print(f"Błąd: {e}")
