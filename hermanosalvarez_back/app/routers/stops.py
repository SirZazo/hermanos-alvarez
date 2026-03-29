@router.get("/")
def get_stops(db: Session = Depends(get_db)):
    return db.query(Stop).all()