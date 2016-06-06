/* cifmin_m.p
 * MODULE
        Финансовый мониторинг
 * DESCRIPTION
        Отчет по мини-карточкам клиента.
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
        16.02.2011 ruslan
 * BASES
        BANK COMM
 * CHANGES
        25.02.2011 ruslan перекомпиляция
        25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко
*/

{global.i}

def var v-name like cifmin.name.
def var v-fname like cifmin.fam.
def var v-lname like cifmin.mname.
def var v_dt1 like cifmin.rwhn.
def var v_dt2 like cifmin.rwhn.
def var v-ofc like bank.ofc.ofc.
def var v-ofile as char no-undo.
def stream rep.
def var v-select as int no-undo.
def var v-log as logical.

def temp-table t-plat
    field tbranch as char
    field tdato as date
    field twho as char
    field fname as char
    field nname as char
    field mname as char
    field tdatb as date
    field tmb as char
    field tdoc as char
    field tdocwho as char
    field tdocwhn as date
    field tiin as char
    field taddr as char.

DEF FRAME frame1
              WITH CENTERED TITLE " ФИО ".

DEF FRAME frame2
              WITH CENTERED TITLE " ПЕРИОД".

def var v-path as char no-undo.

    find first bank.cmp no-lock no-error.
    if not avail bank.cmp then do:
        message " Не найдена запись cmp " view-as alert-box error.
    end.

    if bank.cmp.name matches "*МКО*" then v-path = '/data/'.
    else v-path = '/data/b'.

v-select = 0.
v-ofile = "2.htm".
output stream rep to value(v-ofile).

put stream rep unformatted
             "<table border=1>" skip
             "<tr>" skip
             "<td>Филиал</td>" skip
             "<td>Дата заведения</td>" skip
             "<td>ID менеджера</td>" skip
             "<td>Ф клиента</td>" skip
             "<td>И клиента</td>" skip
             "<td>О клиента</td>" skip
             "<td>Дата рождения</td>" skip
             "<td>Место рождения</td>" skip
             "<td>Номер документа</td>" skip
             "<td>Кем выдан</td>" skip
             "<td>Дата выдачи</td>" skip
             "<td>ИИН</td>" skip
             "<td>Адрес регистрации</td>" skip
             "</tr>" skip.

run sel2 (" Мини-карточки ", " 1. Поиск по ФИО| 2. Поиск по периоду| ВЫХОД ", output v-select).
    if v-select = 0 then return.
    if v-select = 1 then do:
        set v-fname label "Введите Фамилию клиента" with frame a1.
        set v-name label "Введите Имя клиента" with frame a1.
        set v-lname label "Введите Отчество клиента" with frame a1.
         for each cifmin where trim(cifmin.fam) = trim(v-fname) and
                                  trim(cifmin.name) = trim(v-name) and
                                  trim(cifmin.mname) = trim(v-lname) no-lock:
            create t-plat.
            assign
                t-plat.tdato = cifmin.rwhn.
                t-plat.twho = cifmin.rwho.
                t-plat.fname = cifmin.fam.
                t-plat.nname = cifmin.name.
                t-plat.mname = cifmin.mname.
                t-plat.tdatb = cifmin.bdt.
                t-plat.tmb = cifmin.bplace.
                t-plat.tdoc = cifmin.docnum.
                t-plat.tdocwho = cifmin.docwho.
                t-plat.tdocwhn = cifmin.docdt.
                t-plat.tiin = cifmin.iin.
                t-plat.taddr = cifmin.addr.
         end.

         for each comm.txb where comm.txb.consolid and comm.txb.logname <> "rkc" no-lock:
              if connected ("txb") then disconnect "txb".
              connect value(" -db " + replace(comm.txb.path,'/data/',v-path) + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
              for each t-plat where t-plat.tbranch = '' no-lock:
                run get-fil2(t-plat.twho, output v-log).
                if v-log = true then do:
                  t-plat.tbranch = comm.txb.info.
                end.
              end.
         end.
       if connected ("txb") then disconnect "txb".
    end.

    if v-select = 2 then do:
        set v_dt1 label "Введите дату начала периода" format '99/99/99' with frame a2.
        set v_dt2 label "Введите дату конца периода" format '99/99/99' with frame a2.
         for each cifmin where cifmin.rwhn >= v_dt1 and
                                   cifmin.rwhn <= v_dt2 no-lock:
              create t-plat.
              assign
                t-plat.tdato = cifmin.rwhn.
                t-plat.twho = cifmin.rwho.
                t-plat.fname = cifmin.fam.
                t-plat.nname = cifmin.name.
                t-plat.mname = cifmin.mname.
                t-plat.tdatb = cifmin.bdt.
                t-plat.tmb = cifmin.bplace.
                t-plat.tdoc = cifmin.docnum.
                t-plat.tdocwho = cifmin.docwho.
                t-plat.tdocwhn = cifmin.docdt.
                t-plat.tiin = cifmin.iin.
                t-plat.taddr = cifmin.addr.
         end.

         for each comm.txb where comm.txb.consolid and comm.txb.logname <> "rkc" no-lock:
              if connected ("txb") then disconnect "txb".
              connect value(" -db " + replace(comm.txb.path,'/data/',v-path) + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
              for each t-plat where t-plat.tbranch = '' no-lock:
                run get-fil2(t-plat.twho, output v-log).
                if v-log = true then do:
                  t-plat.tbranch = comm.txb.info.
                end.
              end.
          end.
    end.

            for each t-plat no-lock:
              put stream rep unformatted
              "<tr>" skip
             "<td>" t-plat.tbranch "</td>" skip
             "<td>" t-plat.tdato "</td>" skip
             "<td>" t-plat.twho "</td>" skip
             "<td>" t-plat.fname "</td>" skip
             "<td>" t-plat.nname "</td>" skip
             "<td>" t-plat.mname "</td>" skip
             "<td>" t-plat.tdatb "</td>" skip
             "<td>" t-plat.tmb "</td>" skip
             "<td>" t-plat.tdoc "</td>" skip
             "<td>" t-plat.tdocwho "</td>" skip
             "<td>" t-plat.tdocwhn "</td>" skip
             "<td> &nbsp;" t-plat.tiin "</td>" skip
             "<td>" t-plat.taddr "</td>" skip
             "</tr>" skip.
            end.

put stream rep unformatted "</table></body></html>" skip.

output stream rep close.
unix silent cptwin 2.htm excel.


