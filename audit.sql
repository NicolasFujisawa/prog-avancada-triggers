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
    AUD_USER NUMBER(6)
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


create or replace trigger AUDIT_EMPLOYEES
after insert or update or delete on EMPLOYEES
for each row
referencing old as antigo new as novo
declare
	novo_id = id_seq.nextval;
begin

	insert into AUDIT_INFO values (novo_id, sysdate, user);

    /*Se está inserindo grava os nomes*/
    if (INSERTING) then -- inserindo
    	/* inserindo apenas os NOVOS valores na table, TIPO do ddl, AUD id do */
        insert into EMPLOYEE_AUD values (novo_id, 0, :novo.EMPLOYEE_ID, :novo.FIRST_NAME, 
        		:novo.LAST_NAME, :novo.EMAIL, :novo.PHONE_NUMBER,
        		:novo.HIRE_DATE, :novo.JOB_ID, :novo.SALARY, 
        		:novo.COMMISSION_PCT , :novo.MANAGER_ID , :novo.DEPARTMENT_ID);

  
    end if;

    /*atulizando registra os nome antigos e os novos*/
    if (UPDATING) then -- atualizando
        insert into EMPLOYEE_AUD values (novo_id, 1, :antigo.EMPLOYEE_ID, :antigo.FIRST_NAME, 
        		:antigo.LAST_NAME, :antigo.EMAIL, :antigo.PHONE_NUMBER,
        		:antigo.HIRE_DATE, :antigo.JOB_ID, :antigo.SALARY, 
        		:antigo.COMMISSION_PCT , :antigo.MANAGER_ID , :antigo.DEPARTMENT_ID);

        insert into EMPLOYEE_AUD values (novo_id, 2, :novo.EMPLOYEE_ID, :novo.FIRST_NAME, 
        		:novo.LAST_NAME, :novo.EMAIL, :novo.PHONE_NUMBER,
        		:novo.HIRE_DATE, :novo.JOB_ID, :novo.SALARY, 
        		:novo.COMMISSION_PCT , :novo.MANAGER_ID , :novo.DEPARTMENT_ID);

    /*e deletando apenas o ultimo registro da linha*/
    if (DELETING) then -- deletando
    	insert into EMPLOYEE_AUD values (novo_id, 3, :antigo.EMPLOYEE_ID, :antigo.FIRST_NAME, 
        		:antigo.LAST_NAME, :antigo.EMAIL, :antigo.PHONE_NUMBER,
        		:antigo.HIRE_DATE, :antigo.JOB_ID, :antigo.SALARY, 
        		:antigo.COMMISSION_PCT , :antigo.MANAGER_ID , :antigo.DEPARTMENT_ID);

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