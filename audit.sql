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

-- 0- insert
-- 1- update before
-- 2- update after
-- 3- delete
insert into AUDIT_TIPO (AUDIT_TIPO, TIPO) values(0, 'Inserindo');
insert into AUDIT_TIPO (AUDIT_TIPO, TIPO) values(1, 'Antes do update');
insert into AUDIT_TIPO (AUDIT_TIPO, TIPO) values(2, 'Depois do update');
insert into AUDIT_TIPO (AUDIT_TIPO, TIPO) values(3, 'Deletando');


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


CREATE OR REPLACE TRIGGER audit_employees AFTER
    INSERT OR UPDATE OR DELETE ON employees
    FOR EACH ROW

DECLARE
    novo_id NUMBER;

BEGIN
    novo_id := aud_id_seq.nextval;
    INSERT INTO audit_info VALUES (
        novo_id,
        sysdate,
        user
    );

    /*Se está inserindo grava os nomes*/
    IF ( inserting ) THEN -- inserindo
    	/* inserindo apenas os NOVOS valores na table, TIPO do ddl, AUD id do */
        insert into EMPLOYEE_AUD (AUD, AUDIT_TIPO, EMPLOYEE_ID, FIRST_NAME, LAST_NAME, EMAIL, PHONE_NUMBER, HIRE_DATE, JOB_ID, SALARY, MANAGER_ID, DEPARTMENT_ID)
        	values (novo_id, 0, :new.EMPLOYEE_ID, :new.FIRST_NAME, 
        		:new.LAST_NAME, :new.EMAIL, :new.PHONE_NUMBER,
        		:new.HIRE_DATE, :new.JOB_ID, :new.SALARY, 
        		:new.MANAGER_ID , :new.DEPARTMENT_ID);  
    END IF;

    /*atulizando registra os nomes olds e os novos*/
    IF ( updating ) THEN -- atualizando
        INSERT INTO EMPLOYEE_AUD (AUD, AUDIT_TIPO, EMPLOYEE_ID, FIRST_NAME, LAST_NAME, EMAIL, PHONE_NUMBER, HIRE_DATE, JOB_ID, SALARY, MANAGER_ID, DEPARTMENT_ID)
        	values (novo_id, 1, :old.EMPLOYEE_ID, :old.FIRST_NAME, 
        		:old.LAST_NAME, :old.EMAIL, :old.PHONE_NUMBER,
        		:old.HIRE_DATE, :old.JOB_ID, :old.SALARY,
        		:old.MANAGER_ID, :old.DEPARTMENT_ID);

        INSERT INTO EMPLOYEE_AUD (AUD, AUDIT_TIPO, EMPLOYEE_ID, FIRST_NAME, LAST_NAME, EMAIL, PHONE_NUMBER, HIRE_DATE, JOB_ID, SALARY, MANAGER_ID, DEPARTMENT_ID)
        	values (novo_id, 2, :new.EMPLOYEE_ID, :new.FIRST_NAME, 
        		:new.LAST_NAME, :new.EMAIL, :new.PHONE_NUMBER,
        		:new.HIRE_DATE, :new.JOB_ID, :new.SALARY, 
        		:new.MANAGER_ID, :new.DEPARTMENT_ID);
    END IF;

    /*e deletando apenas o ultimo registro da linha*/
    IF ( deleting ) THEN -- deletando
        INSERT INTO EMPLOYEE_AUD (AUD, AUDIT_TIPO, EMPLOYEE_ID, FIRST_NAME, LAST_NAME, EMAIL, PHONE_NUMBER, HIRE_DATE, JOB_ID, SALARY, MANAGER_ID, DEPARTMENT_ID)
    		values (novo_id, 3, :old.EMPLOYEE_ID, :old.FIRST_NAME, 
        		:old.LAST_NAME, :old.EMAIL, :old.PHONE_NUMBER,
        		:old.HIRE_DATE, :old.JOB_ID, :old.SALARY, 
        		:old.MANAGER_ID, :old.DEPARTMENT_ID);
    END IF;

END;


CREATE TRIGGER enviar_boleto AFTER 
	INSERT ON purchase_order
	FOR EACH ROW
BEGIN
	utl_mail.send
	(
		sender =>
			'company@email.com',
		recipients =>
			'someclient@email.com',
		subject =>
			'Novo pedido' || 
			:new.po_number,
			message => 
				'pedido realizado, pague o boleto em anexo..'
	);
END;
