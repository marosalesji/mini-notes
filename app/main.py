from datetime import date
from typing import Optional

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI()

notes = []


class NoteIn(BaseModel):
    text: str
    date: date


def filter_by_date(notes: list, from_date: Optional[date], to_date: Optional[date]):
    return [
        n for n in notes
        if (from_date is None or n["date"] >= from_date.isoformat())
        and (to_date is None or n["date"] <= to_date.isoformat())
    ]


def add_note(notes: list, note: NoteIn):
    new_note = {"text": note.text, "date": note.date.isoformat()}
    notes.append(new_note)
    return new_note


@app.get("/notes")
def get_notes(from_date: Optional[date] = None, to_date: Optional[date] = None):
    if from_date is None and to_date is None:
        return notes
    return filter_by_date(notes, from_date, to_date)


@app.post("/notes", status_code=201)
def create_note(note: NoteIn):
    if not note.text.strip():
        raise HTTPException(status_code=422, detail="text must not be empty")
    return add_note(notes, note)


def remove_note(notes: list, index: int):
    if index < 0 or index >= len(notes):
        return False
    notes.pop(index)
    return True


@app.delete("/notes/{index}", status_code=204)
def delete_note(index: int):
    if not remove_note(notes, index):
        raise HTTPException(status_code=404, detail="note not found")
