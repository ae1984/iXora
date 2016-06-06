/* cs_data.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        22.02.2013 evseev
 * BASES
        BANK COMM
 * CHANGES
        29.05.2013 evseev - recompile
*/

{global.i}

def /*new*/ shared var s-credtype as char init '4' no-undo.
def /*new*/ shared var v-aaa      as char no-undo.
def /*new*/ shared var v-bank     as char no-undo.
def /*new*/ shared var v-cifcod   as char no-undo.

/*
v-aaa = "KZ11470192204A909416".
v-bank = "txb16".
v-cifcod = "T16705".
*/

def var v-companyName as char init '' no-undo.
def buffer b-cif for cif.


find first pkanketa where pkanketa.aaa = v-aaa and pkanketa.credtype = s-credtype no-lock no-error.
if not avail pkanketa then do:
   message "Анкета не найдена!" view-as alert-box question buttons ok.
   return.
end.

function CheckVal returns logi (input parm0 as char, input parm1 as integer).
    if parm0 = "100" then do:
       if parm1 >=0 and parm1 <=14 then return true.
    end.
    if parm0 = "110" then do:
       if parm1 >=1 and parm1 <=14 then return true.
    end.
    if parm0 = "120" then do:
       if parm1 >=15 and parm1 <=19 then return true.
    end.
    if parm0 = "130" then do:
       if parm1 >=19 and parm1 <=24 then return true.
    end.
    if parm0 = "140" then do:
       if parm1 >=25 and parm1 <=30 then return true.
    end.
    if parm0 = "150" then do:
       if parm1 >=31 /*and parm1 <=365*/ then return true.
    end.
end function.

def button btnSave label "Сохранить".
def button btnExit   label "Выход".

def temp-table temp_cs_catalog like codfr
    field val    as int.
def buffer b-temp_cs_catalog for temp_cs_catalog.
def QUERY q_cs_catalog  FOR temp_cs_catalog.
def browse b_cs_catalog query q_cs_catalog displ
        temp_cs_catalog.name[1]   format "x(50)"  label 'Кред.ист.,за посл. 12мес. в БВУ'
        temp_cs_catalog.name[5]  format "x(3)"  label 'Балл'
        temp_cs_catalog.val  format ">>>>9"  label 'Отметка ДМО'
        with 20 down SEPARATORS title "Кредитная история БВУ" overlay.
def frame fCatalog b_cs_catalog skip btnSave btnExit  with centered overlay row 3 width 85 top-only.

def frame fProp
        temp_cs_catalog.val   validate(CheckVal(temp_cs_catalog.code ,temp_cs_catalog.val ) ,'Неверно указано значение')  format ">>>9"  label 'Отметка ДМО (выбирается только одно поле и указывается цифровое значение)' skip
        with side-labels centered row 8 width 85.


find first codfr where codfr.codfr = "kip12mbvu" no-lock no-error.
if avail codfr then do:
    empty temp-table temp_cs_catalog.
    for each codfr where codfr.codfr = "kip12mbvu" no-lock.
      create temp_cs_catalog.
      buffer-copy codfr to temp_cs_catalog.
    end.
    OPEN QUERY q_cs_catalog FOR EACH temp_cs_catalog.
end. else message "У критерия нет справочника! Введите значение" view-as alert-box question buttons ok.
for each  temp_cs_catalog:
   temp_cs_catalog.val = ?.
end.


on "ENTER" of b_cs_catalog IN FRAME fCatalog do:
   run procEdt.
end.

ON CHOOSE OF btnExit IN FRAME fCatalog do:
   return.
end.
ON CHOOSE OF btnSave IN FRAME fCatalog do:
   find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = s-credtype
                      and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "credhistbvu123" no-lock no-error.
   if avail pkanketh then do:
      message "Повторное сохраниние невозможно!" view-as alert-box question buttons ok.
   end. else  run procSave.
end.

run procLoad.
enable all with frame fCatalog.
WAIT-FOR CHOOSE OF btnExit.


/***********процедуры********************************************/
    procedure procEdt:
       find first b-temp_cs_catalog where b-temp_cs_catalog.val <> ? no-lock no-error.
       if avail b-temp_cs_catalog then b-temp_cs_catalog.val = ?.
       displ temp_cs_catalog.val  with frame fProp.
       update  temp_cs_catalog.val  with frame fProp.
       hide frame fProp.
       browse b_cs_catalog:refresh().
    end procedure.

    procedure procSave:
           find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = s-credtype
                                     and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "credhistbvu123" exclusive-lock no-error.
           find first temp_cs_catalog where temp_cs_catalog.val <> ? no-lock no-error.
           if not avail temp_cs_catalog then find current temp_cs_catalog no-lock no-error.
           if avail temp_cs_catalog then do:
               if not avail pkanketh then  create pkanketh.
               pkanketh.bank = pkanketa.bank.
               pkanketh.credtype = s-credtype.
               pkanketh.ln = pkanketa.ln.
               pkanketh.kritcod = "credhistbvu123".
               pkanketh.value1 = temp_cs_catalog.code.
               pkanketh.rescha[1] = string(temp_cs_catalog.val).
               pkanketh.rescha[2] = temp_cs_catalog.name[5].
           end.
       run savelog('cs_cb', pkanketa.cif + " " + pkanketa.aaa + " " + string(pkanketa.ln) + " Данные сохранены").
       message "Данные сохранены!" view-as alert-box question buttons ok.
    end procedure.


    procedure procLoad:
        find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = s-credtype
                                  and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "credhistbvu123" no-lock no-error.
        if avail pkanketh then do:
            find first temp_cs_catalog where  temp_cs_catalog.code =  pkanketh.value1 no-lock no-error.
            if avail temp_cs_catalog then temp_cs_catalog.val = int(pkanketh.rescha[1]).
        end.
    end procedure.