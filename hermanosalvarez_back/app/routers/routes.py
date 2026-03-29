@router.get("/")
def get_routes(db: Session = Depends(get_db)):
    return db.query(Route).all()