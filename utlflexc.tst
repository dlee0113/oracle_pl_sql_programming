begin
   raise utl_file.invalid_&&firstparm;
exception
when others then p.l(sqlcode); p.l(sqlerrm);
end;