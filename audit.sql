/*tabela do hr oracle*/
create table EMPLOYEES(
	EMPLOYEE_ID NOT NULL NUMBER(6),
	FIRST_NAME VARCHAR2(20),
	LAST_NAME NOT NULL VARCHAR2(25),
	EMAIL NOT NULL VARCHAR2(25),
	PHONE_NUMBER VARCHAR2(20),
	HIRE_DATE NOT NULL DATE,
	JOB_ID NOT NULL VARCHAR2(10),
	SALARY NUMBER(8,2),
	COMMISSION_PCT NUMBER(2,2),
	MANAGER_ID NUMBER(6),
	DEPARTMENT_ID NUMBER(4)
);

/*audit using triggers*/ 

create table AUDIT_INFO(
    AUD NUMBER(6),
    AUD_DATA DATE,
    USER NUMBER(6)
);

create table AUDIT_TIPO(
	AUDIT_TIPO NUMBER(6),
	TIPO VARCHAR2(50)
);

create table EMPLOYEE_AUD(
	AUD NUMBER(6),
	AUDIT_TIPO NUMBER(6),
	EMPLOYEE_ID NOT NULL NUMBER(6),
	FIRST_NAME VARCHAR2(20),
	LAST_NAME NOT NULL VARCHAR2(25),
	EMAIL NOT NULL VARCHAR2(25),
	PHONE_NUMBER VARCHAR2(20),
	HIRE_DATE NOT NULL DATE,
	JOB_ID NOT NULL VARCHAR2(10),
	SALARY NUMBER(8,2),
	COMMISSION_PCT NUMBER(2,2),
	MANAGER_ID NUMBER(6),
	DEPARTMENT_ID NUMBER(4)
)


create or replace trigger AUDIT_EMPLOYEES
after insert or update on EMPLOYEES
for each row
referencing old as old new as new
begin

    /*When-Insert block. 1 record for each column in audit*/
    if (INSERTING) then --
    	/* inserindo apenas os NOVOS valores na table, TIPO D*/
        insert into EMPLOYEE_AUD values (id_seq.nextval, 0, :new.EMPLOYEE_ID, :new.FIRST_NAME, 
        		:new.LAST_NAME, :new.EMAIL, :new.PHONE_NUMBER,
        		:new.HIRE_DATE, :new.JOB_ID, :new.SALARY, 
        		:new.COMMISSION_PCT , :new.MANAGER_ID , :new.DEPARTMENT_ID);

        insert into AUDIT_INFO values (id_seq.nextval, sysdate, user)
  
    end if;
    /*end of When-Insert block*/

    /*When-Update block. A new record in audit just for the updated column(s) */
    if (UPDATING) then 
        insert into EMPLOYEE_AUD values (id_seq.nextval, 1, :old., :new.<name of column1>, sysdate, user);
    end if;
    if (UPDATING ( '<name of column2>' )) then --col 2
        insert into EMPLOYEE_AUD values (id_seq.nextval, '<name of column2>', :old.<name of column2>, :new.<name of column2>, sysdate, user);
    end if;
    /*end of When-Update block*/

end;