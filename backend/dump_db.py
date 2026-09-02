import sys
sys.path.insert(0, '.')

from app.core.database_session import engine
from sqlalchemy import text, inspect

inspector = inspect(engine)
tables = inspector.get_table_names()

with engine.connect() as conn:
    for table in sorted(tables):
        result = conn.execute(text(f'SELECT * FROM "{table}" LIMIT 50'))
        rows = result.fetchall()
        cols = result.keys()
        
        print(f"\n{'='*80}")
        print(f"  TABLE: {table.upper()}  ({len(rows)} rows)")
        print(f"{'='*80}")
        
        if not rows:
            print("  (empty)")
            continue
        
        # Column widths
        col_list = list(cols)
        widths = [max(len(str(c)), max((len(str(r[i])[:30]) for r in rows), default=0)) for i, c in enumerate(col_list)]
        
        # Header
        header = " | ".join(str(c).ljust(widths[i]) for i, c in enumerate(col_list))
        sep = "-+-".join("-" * w for w in widths)
        print(header)
        print(sep)
        
        for row in rows:
            line = " | ".join(str(row[i])[:30].ljust(widths[i]) for i in range(len(col_list)))
            print(line)
