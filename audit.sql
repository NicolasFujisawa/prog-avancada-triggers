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

/*audit usando triggers*/ 
create table AUDIT_INFO(
    AUD NUMBER(6) NOT NULL,
    AUD_DATA DATE,
    AUD_USER VARCHAR(40)
);

create table AUDIT_TIPO(
	AUDIT_TIPO NUMBER(6),
	TIPO VARCHAR2(50)
);

insert into AUDIT_TIPO (AUDIT_TIPO, TIPO) values(0, 'Inserindo');
insert into AUDIT_TIPO (AUDIT_TIPO, TIPO) values(1, 'Antes do update');
insert into AUDIT_TIPO (AUDIT_TIPO, TIPO) values(2, 'Depois do update');
insert into AUDIT_TIPO (AUDIT_TIPO, TIPO) values(3, 'Deletando');
-- 0- insert
-- 1- update before
-- 2- update after
-- 3- delete

create table EMPLOYEE_AUD(
	AUD  NUMBER NOT NULL,
	AUDIT_TIPO  NUMBER(6) NOT NULL,
	EMPLOYEE_ID  NUMBER(6) NOT NULL,
	FIRST_NAME VARCHAR2(20),
	LAST_NAME  VARCHAR2(25) NOT NULL,
	EMAIL  VARCHAR2(25) NOT NULL,
	PHONE_NUMBER VARCHAR2(20),
	HIRE_DATE  DATE NOT NULL,
	JOB_ID  VARCHAR2(10) NOT NULL,
	SALARY NUMBER(8,2),
	COMMISSION_PCT NUMBER(2,2),
	MANAGER_ID NUMBER(6),
	DEPARTMENT_ID NUMBER(4)
);

CREATE SEQUENCE aud_id_seq START WITH 0 INCREMENT BY 1;


create or replace trigger AUDIT_EMPLOYEES
after insert or update or delete on EMPLOYEES
for each row
declare
	novo_id NUMBER;
begin
	novo_id := aud_id_seq.nextval;
	insert into AUDIT_INFO values (novo_id, sysdate, user);

    /*Se está inserindo grava os nomes*/
    if (INSERTING) then -- inserindo
    	/* inserindo apenas os NOVOS valores na table, TIPO do ddl, AUD id do */
        insert into EMPLOYEE_AUD (AUD, AUDIT_TIPO, EMPLOYEE_ID, FIRST_NAME, LAST_NAME, EMAIL, PHONE_NUMBER, HIRE_DATE, JOB_ID, SALARY, MANAGER_ID, DEPARTMENT_ID)
        	values (novo_id, 0, :new.EMPLOYEE_ID, :new.FIRST_NAME, 
        		:new.LAST_NAME, :new.EMAIL, :new.PHONE_NUMBER,
        		:new.HIRE_DATE, :new.JOB_ID, :new.SALARY, 
        		:new.MANAGER_ID , :new.DEPARTMENT_ID);  
    end if;

    /*atulizando registra os nomes olds e os novos*/
    if (UPDATING) then -- atualizando
        insert into EMPLOYEE_AUD (AUD, AUDIT_TIPO, EMPLOYEE_ID, FIRST_NAME, LAST_NAME, EMAIL, PHONE_NUMBER, HIRE_DATE, JOB_ID, SALARY, MANAGER_ID, DEPARTMENT_ID)
        	values (novo_id, 1, :old.EMPLOYEE_ID, :old.FIRST_NAME, 
        		:old.LAST_NAME, :old.EMAIL, :old.PHONE_NUMBER,
        		:old.HIRE_DATE, :old.JOB_ID, :old.SALARY,
        		:old.MANAGER_ID, :old.DEPARTMENT_ID);

        insert into EMPLOYEE_AUD (AUD, AUDIT_TIPO, EMPLOYEE_ID, FIRST_NAME, LAST_NAME, EMAIL, PHONE_NUMBER, HIRE_DATE, JOB_ID, SALARY, MANAGER_ID, DEPARTMENT_ID)
        	values (novo_id, 2, :new.EMPLOYEE_ID, :new.FIRST_NAME, 
        		:new.LAST_NAME, :new.EMAIL, :new.PHONE_NUMBER,
        		:new.HIRE_DATE, :new.JOB_ID, :new.SALARY, 
        		:new.MANAGER_ID, :new.DEPARTMENT_ID);
    end if;

    /*e deletando apenas o ultimo registro da linha*/
    if (DELETING) then -- deletando
    	insert into EMPLOYEE_AUD (AUD, AUDIT_TIPO, EMPLOYEE_ID, FIRST_NAME, LAST_NAME, EMAIL, PHONE_NUMBER, HIRE_DATE, JOB_ID, SALARY, MANAGER_ID, DEPARTMENT_ID)
    		values (novo_id, 3, :old.EMPLOYEE_ID, :old.FIRST_NAME, 
        		:old.LAST_NAME, :old.EMAIL, :old.PHONE_NUMBER,
        		:old.HIRE_DATE, :old.JOB_ID, :old.SALARY, 
        		:old.MANAGER_ID, :old.DEPARTMENT_ID);

    end if;

end;

/*
pontos chaves para explicar (se quiser) por slides:
 - trigger 1
 - aonde usar 1
 - aonde não usar 1
 - audit 1 ou 2
 - action 1
 - :novo & :old.. 1
 * código/pratica 5
 */