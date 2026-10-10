from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from typing import List, Dict
from pathlib import Path
import csv

app = FastAPI(title="CampusFlow API", version="1.0.0")
DATA = Path(__file__).with_name("students_sample.csv")

class Student(BaseModel):
    id: str
    name: str
    roll: str
    gender: str
    dob: str
    email: str
    phone: str
    address: str
    year: int = Field(ge=1, le=4)
    branch: str
    section: str
    semester: int = Field(ge=1, le=8)
    admission_year: int
    cgpa: float
    attendance: float
    fees_total: float
    fees_paid: float

students: Dict[str, Student] = {}

def load_data():
    if not DATA.exists():
        return
    with DATA.open(newline="", encoding="utf-8") as f:
        for row in csv.DictReader(f):
            s = Student(
                id=row["id"], name=row["name"], roll=row["roll"], gender=row["gender"],
                dob=row["dob"], email=row["email"], phone=row["phone"], address=row["address"],
                year=int(row["year"]), branch=row["branch"], section=row["section"],
                semester=int(row["semester"]), admission_year=int(row["admission_year"]),
                cgpa=float(row["cgpa"]), attendance=float(row["attendance"]),
                fees_total=float(row["fees_total"]), fees_paid=float(row["fees_paid"]),
            )
            students[s.id] = s

load_data()

@app.get("/")
def root():
    return {"name": "CampusFlow API", "students": len(students), "status": "ok"}

@app.get("/students", response_model=List[Student])
def list_students():
    return list(students.values())

@app.get("/students/{student_id}", response_model=Student)
def get_student(student_id: str):
    if student_id not in students:
        raise HTTPException(404, "Student not found")
    return students[student_id]

@app.post("/students", response_model=Student, status_code=201)
def create_student(student: Student):
    if student.id in students:
        raise HTTPException(409, "Student ID already exists")
    students[student.id] = student
    return student

@app.put("/students/{student_id}", response_model=Student)
def update_student(student_id: str, student: Student):
    if student_id not in students:
        raise HTTPException(404, "Student not found")
    students[student_id] = student.model_copy(update={"id": student_id})
    return students[student_id]

@app.delete("/students/{student_id}")
def delete_student(student_id: str):
    if student_id not in students:
        raise HTTPException(404, "Student not found")
    del students[student_id]
    return {"deleted": student_id}
