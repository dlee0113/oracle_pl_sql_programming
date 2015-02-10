DECLARE
    TYPE nested_type IS TABLE OF NUMBER;
    nt1 nested_type := nested_type(1,2,3);
    nt2 nested_type := nested_type(3,2,1);
    nt3 nested_type := nested_type(2,3,1,3);
    nt4 nested_type := nested_type(1,2,4);
    answer nested_type;
    PROCEDURE show_answer (str IN VARCHAR2)
    IS
       l_row   PLS_INTEGER;
    BEGIN
       DBMS_OUTPUT.put_line (str);
       l_row := answer.FIRST;
    
       WHILE (l_row IS NOT NULL)
       LOOP
          DBMS_OUTPUT.put_line (l_row || '=' || answer (l_row));
          l_row := answer.NEXT (l_row);
       END LOOP;
    
       DBMS_OUTPUT.put_line ('');
    END show_answer;
BEGIN
    answer := nt1 MULTISET UNION nt4; 
	show_answer('nt1 MULTISET UNION nt4');
    answer := nt1 MULTISET UNION nt3; 
	show_answer('nt1 MULTISET UNION nt3');
    answer := nt1 MULTISET UNION DISTINCT nt3;
	show_answer('nt1 MULTISET UNION DISTINCT nt3');
    answer := nt2 MULTISET INTERSECT nt3; 
	show_answer('nt2 MULTISET INTERSECT nt3');
    answer := nt2 MULTISET INTERSECT DISTINCT nt3; 
	show_answer('nt2 MULTISET INTERSECT DISTINCT nt3');
    answer := SET(nt3); 
	show_answer('SET(nt3)');
    answer := nt3 MULTISET EXCEPT nt2; 
	show_answer('nt3 MULTISET EXCEPT nt2');
    answer := nt3 MULTISET EXCEPT DISTINCT nt2; 
	show_answer('nt3 MULTISET EXCEPT DISTINCT nt2');
END;
/