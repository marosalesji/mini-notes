from datetime import date
from fastapi.testclient import TestClient
from app.main import add_note, filter_by_date, remove_note, NoteIn, app

client = TestClient(app)


def test_post_note():
    response = client.post("/notes", json={"text": "hello", "date": "2026-04-12"})
    assert response.status_code == 201
    assert response.json() == {"text": "hello", "date": "2026-04-12"}


def test_add_note():
    notes = []
    note = NoteIn(text="hello", date=date(2026, 4, 12))
    result = add_note(notes, note)
    assert result == {"text": "hello", "date": "2026-04-12"}
    assert notes == [{"text": "hello", "date": "2026-04-12"}]


def test_remove_note():
    notes = [{"text": "a", "date": "2026-04-01"}, {"text": "b", "date": "2026-04-02"}]
    result = remove_note(notes, 0)
    assert result is True
    assert notes == [{"text": "b", "date": "2026-04-02"}]


def test_filter_by_date():
    notes = [
        {"text": "a", "date": "2026-04-01"},
        {"text": "b", "date": "2026-04-10"},
        {"text": "c", "date": "2026-04-20"},
    ]
    result = filter_by_date(notes, date(2026, 4, 5), date(2026, 4, 15))
    assert result == [{"text": "b", "date": "2026-04-10"}]
