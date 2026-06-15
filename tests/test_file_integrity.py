# tests/test_file_integrity.py
import pytest
from pathlib import Path
import os
from file_integrity_diagnosis import generate_diagnostic_report

def test_generate_report_all_found_and_read_only(tmp_path):
    start_path = tmp_path / "ai_crew"
    start_path.mkdir()
    
    project_dir = tmp_path / "game"
    project_dir.mkdir()
    
    (project_dir / "project.godot").touch()
    main_scene = project_dir / "main.tscn"
    main_scene.touch()
    
    # Pobieramy czas modyfikacji przed uruchomieniem diagnozy
    mtime_before = os.path.getmtime(main_scene)
    
    expected = ["project.godot", "main.tscn"]
    report = generate_diagnostic_report(start_path, expected)
    
    assert report["project_root"] == str(project_dir.resolve())
    assert len(report["found"]) == 2
    assert len(report["missing"]) == 0
    
    # Weryfikacja read-only: sprawdzamy czy czas modyfikacji uległ zmianie
    mtime_after = os.path.getmtime(main_scene)
    assert mtime_before == mtime_after

def test_generate_report_some_missing(tmp_path):
    start_path = tmp_path / "ai_crew"
    start_path.mkdir()
    
    project_dir = tmp_path / "game"
    project_dir.mkdir()
    (project_dir / "project.godot").touch()
    
    expected = ["project.godot", "missing_script.gd"]
    report = generate_diagnostic_report(start_path, expected)
    
    assert "project.godot" in report["found"]
    assert "missing_script.gd" in report["missing"]
