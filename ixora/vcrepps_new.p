/* vcrepps_new.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Журнал регистрации паспортов сделок
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * BASES
        BANK COMM
 * AUTHOR
        25.03.2008 galina
 * CHANGES
        03.04.2008 galina   - тип поля psnum изменен на integer
                              добавлено значение по умолчанию переменной v-ciftype = 0.
                              копирование на локальную компьютер пользователя отчета в формате WIN, открытие этого отчета
        18.04.2008 galina   - удаление v-file из домашнего каталога пользователя
        24.04.2008 galina   - не выбирать конракты под типом 5
        28.04.2008 galina   - выбирать только клиентов только данного департамента
        27.05.2008 galina   - выводить в названии - журнал на экспорт или на импорт
        02.07.2008 galina   - присваиваем переменой номер v-depart департамента, а не номер по порядку
        03.07.2008 galina   - исправлена ошибка, если не выбран департамент
        31.10.2008 galina   - убрала перекодировку из KOI в WIN
        03/11/2010 galina   - поправила наименование банка
        22/11/2010 aigul    - сделала отчет консолидированным и добавила поиск по типу контракта
        31.01.2011 aigul    - посик ПС за период, а не за конкретную дату
                              вывод наименования филиала
        14.10.2011 damir    - убрал всякие копирования на диск С, просто вывожу в Excel.
        25/04/2012 evseev   - rebranding. Название банка из sysc или изменил проверку банка или рко
        29.06.2012 damir    - добавил funcvc.i,внедрено Т.З. № 1355.
        07.11.2012 damir    - небольшие изменения на основании С.З. от 07.11.2012.
*/

{vc.i}
{global.i}
{nbankBik.i}
{comm-txb.i}
{funcvc.i}

def var v-sel1      as int.
def var v-banklist  as char.
def var v-txblist   as char.
def var v-bank      as char.

def new shared var v-cif     like cif.cif.
def new shared var v-cifname as char.
def new shared var v-fil     as char.
def new shared var v-filname as char.

define temp-table t-ps
    field bank      as char
    field cif       as char
    field psnum     as char
    field psdate    like vcps.dndate
    field cifname   as char
    field contrnum  as char
    field ctype     as char
    field contrdate like vccontrs.ctdate.

def var v-rdt       as date no-undo.
def var v-rdtb      as date no-undo.
def var v-rdte      as date no-undo.
def var v-depart    as integer no-undo.
def var v-exim      as char init 'E'.
/*def var v-cifname as char no-undo.*/
/*def var v-bank    as char no-undo.*/
def var v-dep       as char no-undo.
def var v-sel       as integer no-undo.
def var v-eximch    as char.
def var v-fulnam    as char.
def var v-txbbank   as char.
def var v-bnkbin    as char.

/**форма ввода параметров отчета**/
form
    skip(1)
    " Период регистрации паспорта сделки" skip(1)
    v-rdtb label " с " format "99/99/9999"
    validate (v-rdt <= g-today, " Дата должна быть не больше текущей!")
    skip(1)
    v-rdte label " по " format "99/99/9999"
    validate (v-rdt <= g-today, " Дата должна быть не больше текущей!")
    skip(1)
    v-exim label "      E) экспорт     I) импорт "
    validate(index("eEiI", v-exim) > 0, "Неверный тип контракта !")
    skip (1)
with centered side-label row 5 title "УКАЖИТЕ ДАТУ ОТЧЕТА" frame f-dt.

v-rdt =  g-today.
v-rdtb =  g-today.
v-rdte =  g-today.
displ v-rdtb v-rdte with frame f-dt.

/**ввод параметров отчета**/
update v-rdtb v-rdte with frame f-dt.
displ v-rdtb v-rdte with frame f-dt.


update v-exim with frame f-dt.
v-exim = caps(v-exim).
displ v-exim with frame f-dt.



/*v-bank = comm-txb().*/
def var s-vcourbank as char.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
    display " There is no record OURBNK in bank.sysc file !!".
    pause.
    return.
end.
s-vcourbank = trim(sysc.chval).

v-banklist = " 0. КОНСОЛИДИРОВАННЫЙ ОТЧЕТ | 1. ЦО | 2. Актобе | 3. Кустанай | 4. Тараз | 5. Уральск | 6. Караганда | 7. Семск | 8. Кокчетав | 9. Астана | 10. Павлодар | 11. Петропавловск | 12. Атырау | 13. Актау | 14. Жезказган | 15. Усть-Каман | 16. Чимкент | 17. Алматы".
v-txblist = "ALL,TXB00,TXB01,TXB02,TXB03,TXB04 ,TXB05,TXB06,TXB07,TXB08,TXB09,TXB10,TXB11,TXB12,TXB13,TXB14,TXB15,TXB16".
v-sel1 = 0.
if s-vcourbank = "TXB00" then do:
    run sel2("ФИЛИАЛЫ",v-banklist,output v-sel1).
    if v-sel1 > 0 then v-bank = entry(v-sel1,v-txblist).
    else return.
    /**выбор СПФ**/
    /*if v-bank <> "ALL" then do:
        find last ofchis where ofchis.ofc = g-ofc no-lock no-error.
        if not avail ofchis then do:
          message 'Нет сведений о пользователе!!!' view-as alert-box.
          return.
        end.
        if ofchis.depart = 1 then do:
            for each ppoint where ppoint.point = ofchis.point no-lock:
                if v-dep <> "" then v-dep = v-dep + " |".
                v-dep = v-dep + string(ppoint.depart) + " " + ppoint.name.
            end.
            v-sel = 0.
            run sel2 (" ВЫБЕРИТЕ ОФИС БАНКА ", v-dep, output v-sel).
            if v-sel = 0  then return.
            v-depart = integer(trim(entry(1,(entry(v-sel,v-dep, '|')),' '))).
        end.
        else v-depart = ofchis.depart.
    end.
    */
    /**формируем временную таблицу для хранения данных**/
    for each vccontrs where (vccontrs.bank = v-bank or v-bank = "ALL") and vccontrs.expimp = v-exim and
    (vccontrs.cttype = '1' or vccontrs.cttype = '5') no-lock:
        v-cifname = "".
        v-filname = "".
        v-cif = vccontrs.cif.
        v-fil = vccontrs.bank.
        /*выбираем клиента данного департамента*/
        /*find cif where cif.cif = vccontrs.cif no-lock no-error.
        if (integer(cif.jame) mod 1000 <> v-depart) then next.
        if avail cif then v-cifname = trim(trim(substring(cif.name, 1, 40)) + " " + trim(cif.prefix)).
        */
        if connected ("txb") then disconnect "txb".
        find first comm.txb where comm.txb.bank = vccontrs.bank and comm.txb.consolid = true no-lock no-error.
        if avail comm.txb then do:
            if connected ("txb") then disconnect "txb".
            connect value(" -db " + replace(comm.txb.path,"/data/","/data/b") + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
            run vcrepps_newcif.
            disconnect "txb".
        end.
        c-vcps:
        for each vcps where vcps.contract = vccontrs.contract and vcps.dntype = '01' no-lock:
           if not (/*vcps.rdt = v-rdt*/ vcps.rdt >= v-rdtb and vcps.rdt <= v-rdte) then next c-vcps.
           create t-ps.
           t-ps.bank        = v-filname.
           t-ps.cif         = vccontrs.cif.
           t-ps.psnum       = vcps.dnnum + string(vcps.num).
           t-ps.psdate      = vcps.dndate.
           t-ps.cifname     = v-cifname.
           t-ps.contrnum    = vccontrs.ctnum.
           t-ps.contrdate   = vccontrs.ctdate.
           t-ps.ctype       = vccontrs.cttype.
        end.
    end.
end.
if s-vcourbank <> "TXB00" then do:
    /**выбор СПФ**/
    find last ofchis where ofchis.ofc = g-ofc no-lock no-error.
    if not avail ofchis then do:
      message 'Нет сведений о пользователе!!!' view-as alert-box.
      return.
    end.
    /*
    if ofchis.depart = 1 then do:
        for each ppoint where ppoint.point = ofchis.point no-lock:
            if v-dep <> "" then v-dep = v-dep + " |".
            v-dep = v-dep + string(ppoint.depart) + " " + ppoint.name.
        end.
        v-sel = 0.
        run sel2 (" ВЫБЕРИТЕ ОФИС БАНКА ", v-dep, output v-sel).
        if v-sel = 0  then return.
        v-depart = integer(trim(entry(1,(entry(v-sel,v-dep, '|')),' '))).
    end.
    else v-depart = ofchis.depart.
    */
    /**формируем временную таблицу для хранения данных**/
    for each vccontrs where vccontrs.bank = s-vcourbank /*and vccontrs.depart = v-depart*/
    and vccontrs.expimp = v-exim and (vccontrs.cttype = '1' or vccontrs.cttype = '5')
    no-lock:
        v-cifname = "".
        v-filname = "".
        v-cif = vccontrs.cif.
        v-fil = vccontrs.bank.
        /*выбираем клиента данного департамента*/
        /*find cif where cif.cif = vccontrs.cif no-lock no-error.
        if (integer(cif.jame) mod 1000 <> v-depart) then next.
        if avail cif then v-cifname = trim(trim(substring(cif.name, 1, 40)) + " " + trim(cif.prefix)).
        */
        if connected ("txb") then disconnect "txb".
        find first comm.txb where comm.txb.bank = vccontrs.bank and comm.txb.consolid = true no-lock no-error.
        if avail comm.txb then do:
            if connected ("txb") then disconnect "txb".
            connect value(" -db " + replace(comm.txb.path,"/data/","/data/b") + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
            run vcrepps_newcif.
            disconnect "txb".
        end.

        c-vcps:
        for each vcps where vcps.contract = vccontrs.contract and vcps.dntype = '01' no-lock:
           if not (/*vcps.rdt = v-rdt*/ vcps.rdt >= v-rdtb and vcps.rdt <= v-rdte) then next c-vcps.
           create t-ps.
           t-ps.bank        = v-filname.
           t-ps.cif         = vccontrs.cif.
           t-ps.psnum       = vcps.dnnum + string(vcps.num).
           t-ps.psdate      = vcps.dndate.
           t-ps.cifname     = v-cifname.
           t-ps.contrnum    = vccontrs.ctnum.
           t-ps.contrdate   = vccontrs.ctdate.
           t-ps.ctype       = vccontrs.cttype.
        end.
    end.
end.
if v-exim = 'E' then v-eximch = 'экспорт'.
else v-eximch = 'импорт'.

/* вывод временной таблицы */
def stream vcps.
/*def var v-file0 as char.*/
def var v-file as char.
def var v-str as char.
/*v-file0 = 'gurnalps.0_' + string(v-rdt,'99.99.99') + '.htm'.*/
v-file = 'gurnalps_' + string(v-rdt,'99.99.99') + '.htm'.

output stream vcps to value(v-file).

{ html-title.i &stream = " stream vcps " }

put stream vcps unformatted
    "<P align=right><FONT size=2>Приложение 3 <br> к Правилам осуществления <br> экспортно-импортного валютного контроля <br>
    в Республике Казахстан, <br> утвержденным постановлением Правления <br> Национального Банка Республики Казахстан <br>
    от 24.02.2012 № 42</FONT></P>" skip.

put stream vcps unformatted
    "<P align=center><FONT size=2>Журнал <br> регистрации контрактов</FONT></P>" skip.

/*find bankl where bankl.bank = v-bank no-lock no-error.
if avail bankl then */

if s-vcourbank = "TXB00" then v-txbbank = v-nbankru.
if v-bank <> "TXB00" and s-vcourbank = "TXB00" then do:
    /*find first txb where txb.bank = v-bank no-lock no-error.
    if avail txb then v-txbbank = txb.info.*/
    if not (v-bank begins "TXB") then v-bank = "TXB00".
    run RECNAME(v-bank,output v-txbbank,output v-bnkbin).
end.
if s-vcourbank <> "TXB00" then do:
    /*find first txb where txb.bank = s-vcourbank no-lock no-error.
    if avail txb then v-txbbank = txb.info.*/

    run RECNAME(s-vcourbank,output v-txbbank,output v-bnkbin).
end.

put stream vcps unformatted
    "<P align=left><FONT size=2>Наименование банка учетной регистрации контракта&nbsp;&nbsp;&nbsp;" v-txbbank "</FONT></P>" skip
    "<P align=left><FONT size=2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    начат в _____ году</FONT></P>" skip
    "<P align=left><FONT size=2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    окончен в _____ году</FONT></P>" skip.

put stream vcps unformatted
    "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""0"">" skip.

put stream vcps unformatted
    "<TR align=center><B>" skip
    "<td><FONT size=2>№</FONT></td>" skip
    "<td><FONT size=2>Дата присвоения учетного <br> номера контракта</FONT></td>" skip
    "<td><FONT size=2>Наименование или фамилия, имя, <br> отчество экспортера или <br> импортера</FONT></td>" skip
    "<td><FONT size=2>Реквизиты контракта</FONT></td>" skip
    "</B></TR>" skip
    "<TR align=center><B>" skip
    "<td><FONT size=2>1</FONT></td>" skip
    "<td><FONT size=2>2</FONT></td>" skip
    "<td><FONT size=2>3</FONT></td>" skip
    "<td><FONT size=2>4</FONT></td>" skip
    "</B></TR>" skip.

def var j as int.
if s-vcourbank = "TXB00" then do:
    for each t-ps break by t-ps.psnum:
        /*if first-of(t-ps.bank) then do:
            put stream vcps unformatted
            "<tr><td>" t-ps.bank "</td>"
            "<td><font size=1>"  "</td>"
            "<td><font size=1>"  "</td>"
            "<td><font size=1>"  "</td>"
            "<td><font size=1>"  "</td>"
            "<td><font size=1>"  "</td></tr>" skip.
        end.
        j = j + 1.*/
        put stream vcps  unformatted
            "<TR align=center>" skip
            "<td><FONT size=2>" t-ps.psnum "</FONT></td>" skip
            "<td><FONT size=2>" string(t-ps.psdate,"99/99/9999") "</FONT></td>" skip
            "<td><FONT size=2>" t-ps.cifname "</FONT></td>" skip
            "<td><FONT size=2>" t-ps.contrnum + "&nbsp;&nbsp;" +  string(t-ps.contrdate,"99/99/9999") "</FONT></td>" skip
            "</TR>" skip.
    end.
end.
else do:
    for each t-ps break by t-ps.psnum:
        /*j = j + 1.*/
        put stream vcps unformatted
            "<TR align=center>"
            "<td><FONT size=2>" t-ps.psnum "</FONT></td>" skip
            "<td><FONT size=2>" string(t-ps.psdate,"99/99/9999") "</FONT></td>" skip
            "<td><FONT size=2>" t-ps.cifname "</FONT></td>" skip
            "<td><FONT size=2>" t-ps.contrnum + "&nbsp;&nbsp;" +  string(t-ps.contrdate,"99/99/9999") "</FONT></td>" skip
            "</TR>" skip.
    end.
end.

put stream vcps unformatted
    "</TABLE>".

/*find bankl where bankl.bank = v-bank no-lock no-error.
if avail bankl then
  put stream vcps unformatted "<B><tr align=""left""><font size=""2"">" bankl.name skip.*/

{ html-end.i }

output stream vcps close.

unix silent cptwin value(v-file) excel.

/*перекодировка из формата KOI8 в WIN**/
/*unix silent value("cat " + v-file0 + " | koi2win > " + v-file + ";rm " + v-file0).*/

/*Копирование на локальную машину пользователя**/
/*input through value("scp -q " + v-file + " Administrator@`askhost`:C:/VK/OTCHET/;echo $?").
repeat:
import unformatted v-str.
end.
if v-str <> "0" then
message v-str + "Необходимо создать папку C:/VK/OTCHET/" view-as alert-box.

unix silent rm -f value (v-file).*/

/**создаем файл run.cmd**/
/*def stream run_cmd.
output stream run_cmd to value('run.cmd').
put stream run_cmd unformatted
"start excel C:\\VK\\OTCHET\\" + v-file skip.
output stream run_cmd close.

input through value("scp -q run.cmd Administrator@`askhost`:C:/tmp/;echo $?").
repeat:
import unformatted v-str.
end.
if v-str <> "0" then
message v-str + "Ошибка копирования файла!" view-as alert-box.*/

hide all no-pause.

