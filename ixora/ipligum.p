/* ipligum.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * BASES
        BANK COMM IB
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        tsoy 24.11.2005 добавил тип аутентификации
        tsoy 16.01.2006 изменил  001122 на абракадабру
        tsoy 18.01.2006 исправил граматическую ошибку
        29.06.11   id00004 убрал некоторые кнопки согласно ТЗ-1055
        09.12.2011 id00004 добавил выбор режима Просмотр, Полный доступ
        14/12/2011 evseev - ТЗ-625. переход на ИИН/БИН
        27.08.2012 evseev - иин/бин
 */


/*  Internet Banking
    Teller menu
    User registration
    Assigning/editing user cif, contact
    Assigning//Deleting key tables, payment cards
    Alexey Truhan (sweer@rkb.lv),
    May 1998





*/
/* 01.10.02 nadejda - наименование клиента заменено на форма собств + наименование */


{chbin.i}

define variable i as int.
define variable s as char.
define stream schdet .

/* ******     V A R I A B L E S      ***** */

define shared variable g-ofc as char.
define shared variable ib-brnch as char.

def new shared var g-action as int.
def new shared var g-usrid like usr.id.
def new shared var g-usrcif like usr.cif.


define variable is_new as logical.
define variable ikanum as int.
define variable ikdnum as int.
define variable scdnum as char.

define button bt-user label "Редактировать" .

def stream rep.

/*------------ no cards ------------
define button bt-crdadd label "Добавить" .
define button bt-crddel label "Удалить".
define button bt-crdshw label "Просмотреть".
------------ no cards ------------*/
def button bt-keyadd label "Выдать".
def button bt-keydel label "Удалить".
def button bt-keyshw label "Просмотреть".
def button bt-exit label "Выход".

def button bt-pin label "Печать OTP PIN и Первичный Пароль".
def button bt-dit label "Сообщение в ДИТ".

def button bt_addshare label "Добавить".
def button bt_viewshare label "Просмотреть".
def button bt_remshare label "Убрать".

def var v-usrid like usr.id format ">>>>>>>>9" init "0" label "ID пользователя".
def frame fr1 v-usrid help "F2 - вывести список" with centered side-labels.

def buffer bf for usr.
/* ******     F R A M E S       ***** */

define frame ibtmain
    usr.id format ">>>>>>9" label " IO клиент" view-as text space(4) bt-user space(16) bt-exit skip
    with centered side-labels.



def temp-table shar
    field id as int init 0 format ">>>>>>>>9" label "ID"
    field login as char format "x(20)" label "Login"
.

define new shared frame ibtuser
    usr.cif format "x(7)" label "CIF"
    skip
    usr.contact[1] format "x(40)" label "Название, ФИО"
    skip
    usr.login format "x(20)" label "Входное имя"
    skip
    usr.contact[2] format "x(20)" label "ИИН/БИН"
    skip
    usr.contact[3] format "x(20)" label "Телефон"
    skip
    usr.contact[4] format "x(60)" label "Адрес 1"
    skip
    usr.contact[5] format "x(60)" label "Адрес 2"
    skip
    cif-mail.mail /*usr.e_mail[1]*/  format "x(60)" label "E-почта"
    skip
    usr.authptype format "x(3)" label "Тип пароля" help "otp или пусто"
    skip
/*    usr.varatr[9] format "x(60)"  label "Открытый ключ" help "Внесите открытый ключ клиента"   */
    usr.ip_trust[20] label "Признак доступа" validate(usr.ip_trust[20] = "режим <ПРОСМОТР>" or usr.ip_trust[20] = "режим <ПОЛНЫЙ ДОСТУП>", "неверное значение нажмите F2 для выбора ") help "Выберите признак доступа (F2)"
    with side-labels centered color message
.

/* form usr.varatr[9]  format "x(160)"  with frame y  overlay row 14 centered top-only no-label. */


on help of usr.ip_trust[20] in frame ibtuser do:
    run sel ("Выберите тип доступа", "режим <ПРОСМОТР>|режим <ПОЛНЫЙ ДОСТУП>").
    if int(return-value) = 1 then usr.ip_trust[20] = "режим <ПРОСМОТР>". else usr.ip_trust[20] = "режим <ПОЛНЫЙ ДОСТУП>".
    displ usr.ip_trust[20] with frame ibtuser.
end.


def query qr for shar scrolling.
def browse br query qr no-lock display shar.id shar.login with no-row-markers no-box 15 down.

define frame ibtshare br with centered row 10 scroll 1 1 down overlay.




/* ******     T R I G G E R S       ***** */

do transaction:




on "choose" of bt-user do:
    if usr.cif = 'no-cif' then
       display usr.cif usr.login usr.contact /*usr.e_mail[1]*/  authptype /*usr.varatr[9]*/ usr.ip_trust[20] with frame ibtuser.
    else do:
       find last cif-mail where cif-mail.cif = usr.cif exclusive-lock no-error.
       display usr.cif usr.login usr.contact /*usr.e_mail[1]*/ cif-mail.mail authptype /*usr.varatr[9]*/ usr.ip_trust[20] with frame ibtuser.
    end.
    enable all with frame ibtmain.

    if is_new then
    do:
      update usr.cif with frame ibtuser.
      g-usrcif = usr.cif.

/*    if frame-value <> usr.cif then */
        find cif where cif.cif = /* frame-value */ usr.cif no-lock no-error.
        find last cif-mail where cif-mail.cif =  usr.cif exclusive-lock no-error.
        create ib.hist.
        assign
            ib.hist.type1 = 2
            ib.hist.type2 = 3
            ib.hist.procname = "IB_Platon_Menu"
            ib.hist.ip_addr = "platon"
            ib.hist.ip_name = g-ofc
            ib.hist.idusraff = usr.id
            ib.hist.changes = "cif[" + usr.cif + "|" + frame-value + "]".
        .
        release ib.hist.
        if not available cif then do:
            usr.cif = "------".
            usr.contact[1] = "".
            usr.contact[2] = "".
            usr.contact[3] = "".
            usr.contact[4] = "".
            usr.contact[5] = "".
/*            usr.varatr[1] = "".
            usr.varatr[2] = "".         */
        end. else do:
/*            usr.cif = frame-value. */
            usr.contact[1] = trim(trim(cif.prefix) + " " + trim(cif.name)).
            if v-bin then usr.contact[2] = cif.bin.
            else usr.contact[2] = cif.jss.
            usr.contact[3] = cif.tel.
            usr.contact[4] = cif.addr[1] + " " + cif.addr[2].
            usr.contact[5] = cif.addr[3].
            usr.varatr[1] = (if substring(cif.geo, length(cif.geo), 1) = "1" then "R" else "N").
            usr.varatr[2] = (if substring(string(cif.cgr), length(string(cif.cgr)) - 2, 1) = "5" then "P" else "C").
            usr.perm[3] = 2.
        end.
    end.
    if usr.cif = '------' then
       display usr.login usr.contact usr.authptype /*usr.varatr[9]*/ usr.ip_trust[20] with frame ibtuser.
    else
       display usr.login usr.contact /* usr.varatr[1] usr.varatr[2] usr.e_mail[1]*/ cif-mail.mail usr.authptype /*usr.varatr[9]*/ usr.ip_trust[20] with frame ibtuser.
    find cif where cif.cif = usr.cif no-lock no-error.



    if not (available cif) then do:
            usr.authptype = "otp".
            update /*usr.login*/ usr.contact /*usr.e_mail[1]*/  /*usr.authptype*/ cif-mail.mail   usr.ip_trust[20]
/*                 usr.varatr[1]
                   usr.varatr[2]  */
                   with frame ibtuser.

/*            update usr.varatr[9]   with frame y scrollable.
            if length(usr.varatr[9]) <> 160 then do:
               message  "Внимание Значение ключа не содержит 160 символов"  view-as alert-box.
            end. */

    end. else do:
                usr.authptype = "otp".
                update /*usr.login*/ usr.contact[3] usr.contact[5] /*usr.e_mail[1]*/ /*usr.authptype*/ cif-mail.mail usr.ip_trust[20] with frame ibtuser.
                /*update usr.varatr[9] with frame y scrollable. */
    end.
    repeat i = 1 to 5 :
            usr.contact[i] = replace(usr.contact[i], "~"", "'").
            usr.contact[i] = replace(usr.contact[i], "<", "(").
            usr.contact[i] = trim(replace(usr.contact[i], ">", ")")).
    end.

end.



/* ******     M A I N   C O D E   B L O C K      ***** */

repeat :
        v-usrid = 0.
        g-usrcif = ''.
        g-action = 3.

        update v-usrid label "Код клиента Интернет Офиса" help "ENTER - ввести нового. F2 - вывести список" with frame fr1 no-error.
        hide frame fr1.


        find usr where usr.id = v-usrid no-lock no-error.

/*
        find first cardd where cardd.id_usr = v-usrid no-lock no-error.
*/
        find first otktd where otktd.id_usr = v-usrid no-lock no-error.
        find first doc where doc.id_usr = v-usrid no-lock no-error.

        if not avail usr then is_new = yes.
                         else is_new = no.

        if is_new then do:
           update is_new label "Создать новую запись?" with row 6 centered side-labels frame fgetnew.
           hide frame fgetnew.
           if not is_new then next.
        end.

        if ((not available usr) and (not available cardd) and (not available otktd)
           and (not available doc)) or ( v-usrid = 0 ) then do:
                   run IBPL_CrUsr (g-ofc, input-output v-usrid).
        end.
        find usr where usr.id = v-usrid exclusive-lock.


        if usr.bnkplc <> ib-brnch then do:
                message "Пользователь не в Вашем филиале.".
        end. else if usr.perm[6] = 1 then do:
                message "Договор закрыт.".
        end. else leave.
        pause 10.
        v-usrid = 0.
end.

if error-status:error and (not available usr) then do:  return. end.
display usr.id with frame ibtmain.

        find last cif-mail where cif-mail.cif = usr.cif no-lock no-error.

if is_new  then
  display usr.cif usr.login usr.contact /*usr.e_mail[1]*/  usr.authptype /*usr.varatr[9]*/ usr.ip_trust[20] with frame ibtuser.
else
  display usr.cif usr.login usr.contact /*usr.e_mail[1]*/  cif-mail.mail usr.authptype /*usr.varatr[9]*/ usr.ip_trust[20] with frame ibtuser.

g-usrcif = usr.cif.
g-usrid = usr.id.
enable all with frame ibtmain.
wait-for "choose" of bt-exit.
end.

/*  I B P L _ C R E A T E _ U S E R       */

PROCEDURE IBPL_CrUsr :
def input parameter tlr as char.
def input-output parameter idusr as int.

        DEF VAR i AS INT NO-UNDO.

        def var v-s as char no-undo.

        CREATE usr.
        CREATE ib.hist.
        ASSIGN
        usr.contact[1] = ''
        usr.contact[2] = ''
        usr.contact[3] = ''
        usr.contact[4] = ''
        usr.contact[5] = ''
        usr.cif        = 'no-cif'
        usr.otk_index  = 1

        usr.perm[1]    = 2                    /* use IB = rw */
        usr.perm[2]    = 0                    /* manage users = no */
        usr.perm[3]    = 0                    /* no blocking */
        usr.perm[4]    = 1                    /* must change password */
        usr.perm[5]    = 1
        usr.perm[6]    = 0                    /* Open */

        usr.pref[5]    = 1                    /* use graphics */
        usr.pref[6]    = 5                    /* documents visible period */

        usr.block_date = 01/01/2000
        usr.bnkplc     = ib-brnch
        usr.varatr[1]  = 'R'
        usr.varatr[2]  = 'P'

        ib.hist.type1     = 2
        ib.hist.type2     = 1
        ib.hist.procname  = "IBPL_CrUsr"
        ib.hist.ip_addr   = "platon"
        ib.hist.ip_name   = tlr
        .

        usr.passwd[5] = substring(encode(tlr + string(time)), 1,6) + substring(string(time),4,2).

        input through value("genkey.exe -p " + usr.passwd[5] ) no-echo.
        repeat:
           import unformatted v-s.
        end.

        usr.passwd[1] = v-s.
        usr.passwd[2] = v-s.
        usr.passwd[3] = v-s.


/*        disp "idusr=" idusr. pause.*/

        if idusr = 0 then idusr = usr.id. else usr.id = idusr.
        ib.hist.idusraff = usr.id.
/*      usr.login = string(usr.id). */
        usr.login = "mcb" + string(next-value(ibuser)) .

        RELEASE ib.hist.
        RELEASE usr.

END PROCEDURE.

PROCEDURE GetCardOwnerName:

def input parameter crdnum as char.
def output parameter coname as char. /* "-" - bad card number */

def var s as char no-undo.
def var i as int no-undo.

        s = "/usr/cards/bin/getchdet -pan" + crdnum + " -show-description".
        coname = "-".
        input stream schdet through value(s) no-echo no-map no-convert.
        s = "".
        repeat:
                import stream schdet unformatted s no-error.
                leave.
        end.
        if error-status:error then s = "".
        input stream schdet close.

        i = index(s, "embossing_name=").
        if i = 0 then do:
                message "Nav kartes ar numuru " + crdnum.
                pause 5. return.
        end.
        s = substring (s, i + 15).
        coname = substring (s, 1, index (s, "|") - 1).
        return.

END PROCEDURE.
