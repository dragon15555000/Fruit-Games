# file_integrity_diagnosis.py
from pathlib import Path
from godot_discovery import find_godot_project_root

def generate_diagnostic_report(start_path: Path, expected_files: list[str]) -> dict:
    """
    Generuje raport diagnostyczny w trybie read-only, sprawdzając
    obecność oczekiwanych plików w korzeniu projektu.
    """
    try:
        project_root = find_godot_project_root(start_path)
    except FileNotFoundError:
        raise FileNotFoundError("Nie można wygenerować raportu: brak korzenia projektu.")

    report = {
        "project_root": str(project_root),
        "found": [],
        "missing": []
    }

    # Weryfikacja fizycznego istnienia każdego pliku z listy
    for file_name in expected_files:
        file_path = project_root / file_name
        if file_path.exists() and file_path.is_file():
            report["found"].append(file_name)
        else:
            report["missing"].append(file_name)

    return report

def print_diagnostic_report(report: dict) -> None:
    """Funkcja pomocnicza do ładnego wypisywania raportu."""
    print(f"=== Raport Diagnostyczny ===")
    print(f"Ścieżka bazowa: {report['project_root']}\n")
    
    print("Znalezione pliki:")
    for f in report['found']:
        print(f" [OK]   {f}")
        
    print("\nBrakujące pliki:")
    for f in report['missing']:
        print(f" [BRAK] {f}")
    print("============================")
