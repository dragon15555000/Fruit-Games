# tests/test_godot_discovery.py
import pytest
from pathlib import Path
from godot_discovery import find_godot_project_root

def test_find_project_root_success(tmp_path):
    # Symulacja struktury: /tmp/.../projects/ai_crew oraz /tmp/.../projects/my_game
    start_path = tmp_path / "ai_crew"
    start_path.mkdir()
    
    project_dir = tmp_path / "my_game"
    project_dir.mkdir()
    
    godot_file = project_dir / "project.godot"
    godot_file.touch() # Tworzymy fizyczny plik
    
    result = find_godot_project_root(start_path)
    assert result == project_dir.resolve()

def test_find_project_root_not_found(tmp_path):
    # Symulacja struktury bez pliku project.godot
    start_path = tmp_path / "ai_crew"
    start_path.mkdir()
    
    with pytest.raises(FileNotFoundError):
        find_godot_project_root(start_path)

def test_no_hardcoded_names():
    # Sprawdzamy kod źródłowy pod kątem zakazanego słowa (podzielonego, by test sam nie oblał)
    with open('godot_discovery.py', 'r', encoding='utf-8') as f:
        content = f.read()
        assert "Fruit" + "-" + "Game" not in content
