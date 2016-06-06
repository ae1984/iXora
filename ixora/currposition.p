/* currposition.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание - Валютная позиция
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню - п.м. 8.8.5.24
 * AUTHOR
        --/--/2012 damir
 * BASES
        BANK COMM
 * CHANGES
        25.06.2012 damir.
        28.06.2012 damir - ограничение по времени запуска.
        04.07.2012 damir - добавил FileExist, вытаскиваем сформированные данные с /data/reports/valpoz/.
        26.07.2012 damir - сделано Доп.Т.З., добавил VPDays, расчет Доходы/Расходы от переоценки за день и нетто позиция.
        04.01.2012 damir - Убрал проверку по v-weekbeg,v-weekend в Getdatests.
*/

{mainhead.i}

/*def var ttime as integer no-undo.
find first pksysc where pksysc.credtype = '0' and pksysc.sysc = "spfbos" no-lock no-error.
if not(avail pksysc and pksysc.loval) then do:
    ttime = time.
    if ttime > 32400 and ttime < 64800 then do:
        message skip "Данный отчет сильно влияет на производительность системы,~nпоэтому отчет можно формировать только в период времени с 18:00 до 09:00.~n~n" +
                "В случае крайней необходимости срочного формирования отчета обратитесь в техподдержку." skip(1) view-as alert-box information.
        return.
    end.
end.*/


def var v-dtmas          as date.
def var v-file           as char init "Curspos.htm".
def var v-file2          as char init "Curspos2.htm".
def var v-clog           as logi init no.
def var v-ch             as char.
def var v-str            as char.
def var v-filer          as char.
def var v-sumtrebobal    as deci.
def var v-sumobyazbal    as deci.
def var v-sumtrebovnebal as deci.
def var v-sumobyazvnebal as deci.
def var v-strcrc         as char.
def var v-summa1         as deci format "zzzzzzzzzzzzzzzzzzzzz9.99".
def var v-summa2         as deci format "zzzzzzzzzzzzzzzzzzzzz9.99".
def var v-tmpsum1        as deci.
def var v-tmpsum2        as deci.

def new shared var RepPath   as char init "/data/reports/valpoz/".
def new shared var RepName   as char.
def new shared var v-gl1     as char init "4593,4703,4704,4705,4707,4710,4734".
def new shared var v-gl2     as char init "5593,5703,5704,5705,5708,5710,5734".
def new shared var v-dt      as date.
def new shared var v-sumdoh1 as deci.
def new shared var v-sumdoh2 as deci.
def new shared var i         as inte.
def new shared var k         as inte.
def new shared var v-weekbeg as inte.
def new shared var v-weekend as inte.

def new shared temp-table tgl
    field bank   as char
    field gl     as inte
    field crc    as inte
    field sumval as deci
    field sumkzt as deci
    field dt     as date
    index tgl-id1 is primary gl ascending
                             dt ascending.

def new shared temp-table t-glfil
    field priz as char
    field summ as deci.

def temp-table t-valpozsv
    field val as deci format "zzz,zzz,zzz,zzz,zzz,zz9.99-"
    field crc as inte
    field num as inte
    field dt  as date
index idxn num ascending
           dt  ascending.

def temp-table t-pozbal
    field crc       as inte
    field balacc    as deci format "zzz,zzz,zzz,zzz,zzz,zz9.99-"
    field vnebalacc as deci format "zzz,zzz,zzz,zzz,zzz,zz9.99-"
    field dt        as date
index idxnum crc ascending
             dt  ascending.

def temp-table t-gravalpoz
    field dt      as date
    field crc     as inte
    field openpoz as deci
    field dohrash as deci.

def temp-table t-dohzaden
    field dt      as date
    field sumgod  as deci format "zzz,zzz,zzz,zzz,zzz,zz9"
index idxdt is primary dt ascending.

def temp-table t-nbrk
    field crc    as inte
    field crcdes as char
    field reit   as char
    field norm   as deci
    field limi   as char
    field vnut   as deci
    field vnli   as char.

def temp-table t-NettPos
    field dt     as date
    field bal    as deci
    field vnebal as deci
    field sum    as deci.

def new shared temp-table t-crc     like crc.
def new shared temp-table t-crchis  like crchis.
def new shared temp-table t-crcpro  like crcpro.

def stream v-out.
output stream v-out to value(v-file).

def stream v-out2.
output stream v-out2 to value(v-file2).

def buffer b-t-crcpro       for t-crcpro.
def buffer b-t-valpozsv     for t-valpozsv.
def buffer b2-t-valpozsv    for t-valpozsv.
def buffer b-t-pozbal       for t-pozbal.
def buffer b2-t-pozbal      for t-pozbal.
def buffer b-t-gravalpoz    for t-gravalpoz.
def buffer b-cls            for cls.
def buffer b-tgl            for tgl.
def buffer b2-tgl           for tgl.
def buffer b-t-dohzaden     for t-dohzaden.

/**находим первый день недели***************************************************************/
find sysc where sysc.sysc = "WKSTRT" no-lock no-error.
if avail sysc then v-weekbeg = sysc.inval.
else v-weekbeg = 2.
/*******************************************************************************************/

/**находим последний день недели************************************************************/
find sysc where sysc.sysc = "WKEND" no-lock no-error.
if avail sysc then v-weekend = sysc.inval.
else v-weekend = 6.
/*******************************************************************************************/

/************************определение - рабочий день или нет ********************************/
function Getdatests returns logi(input dt as date):
    def var s-bday as logi.
    find hol where hol.hol = dt no-lock no-error.
    if not available hol /*and weekday(dt) ge v-weekbeg and  weekday(dt) le v-weekend*/ then s-bday = yes.
    else s-bday = no.
    return s-bday.
end function.
/*******************************************************************************************/

form
    v-dt no-label format "99/99/9999" validate(v-dt <= g-today, "Дата не должна быть больше текущей !") skip
with row 5 centered title "Укажите дату отчета" frame currpos.

update v-dt with frame currpos.
displ v-dt with frame currpos.

function FileExist returns log (input v-name as char).
    def var v-result as char init "".

    input through value ("cat " + v-name + " &>/dev/null || (NO)").
    repeat:
        import unformatted v-result.
    end.
    if v-result = "" then return true.
    else return false.
end function.

procedure VALPOZINPUT:
    def input parameter p-dt as date.

    RepName = "valpoz_" + replace(string(p-dt,"99/99/9999"),"/","-") + ".rep".

    if p-dt <> g-today then do:
        if FileExist(RepPath + RepName) then do:
            /*Вытаскиваем данные из отчета (п.м. 7.4.3.5)*/
            i = 0.
            input from value(RepPath + RepName) no-echo.
            repeat:
                v-str = "".
                import unformatted v-str.
                v-str = trim(v-str).
                if v-str <> "" then do:
                    v-str = replace(v-str,"","").
                    i = i + 1.
                    create t-valpozsv.
                    t-valpozsv.val = deci(entry(1,v-str,";")).
                    t-valpozsv.crc = inte(entry(2,v-str,";")).
                    t-valpozsv.num = i.
                    t-valpozsv.dt  = p-dt.
                end.
            end.
            input close.
        end.
    end.
    else do:
        if not FileExist(RepPath + RepName) then do:
            run valpozsv(p-dt,"CRCPOS").
        end.
    end.
end.

message "Идет обработка данных, ждите ...".

/*Консолидировано собираем данные по всем филиалам*/
{ r-branch.i &proc = "currpositiontxb" }
/*------------------------------------------------*/

/*Вытаскиваем данные из отчета п.м. 7.4.3.5. Начиная с первого числа отчетного месяца по введенную дату отчета*/
/*Из истории закрытия операционных дней*/
for each cls where cls.whn >= date(month(v-dt),1,year(v-dt)) and cls.whn <= v-dt no-lock break by cls.whn:
    if Getdatests(cls.whn) then run VALPOZINPUT(cls.whn).
end.
/*------------------------------------------------------------------------------------------------------------*/

{html-title.i &stream = "stream v-out"}

put stream v-out unformatted
    "<P align=center color=blue style='font-size:12pt'><B>Валютная позиция банка за &nbsp;&nbsp;" string(v-dt,"99/99/9999") "</B></P>" skip.
put stream v-out unformatted
    "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""0"">" skip.
put stream v-out unformatted
    "<TR align=center color=blue style='font-size:10pt'><B>" skip
    "<TD>Средневзвешенный курс</TD>" skip
    "<TD>" string(v-dt,"99/99/9999") "</TD>" skip
    "<TD>Абс. изменение к <br> пред. дню</TD>" skip
    "<TD>Отн. изменение к <br> пред. дню</TD>" skip
    "<TD>Прогнозный курс</TD>" skip
    "</B></TR>" skip.

for each t-crc where t-crc.crc >= 2 and t-crc.crc <= 4 no-lock break by t-crc.crc:
    v-clog = no.
    put stream v-out unformatted
        "<TR align=center style='font-size:10pt'><B>" skip
        "<TD>" t-crc.code "</TD>" skip.
    find last t-crcpro where t-crcpro.crc = t-crc.crc and t-crcpro.regdt <= v-dt no-lock no-error.
    if avail t-crcpro then put stream v-out unformatted
        "<TD>" replace(replace(string(t-crcpro.rate[1],"-zzz,zz9.99"),".",","),".",",") "</TD>" skip.
    else put stream v-out unformatted
        "<TD></TD>" skip.
    find last cls where cls.whn < v-dt no-lock no-error.
    if avail cls then do:
        find last b-t-crcpro where b-t-crcpro.crc = t-crc.crc and b-t-crcpro.regdt = cls.whn no-lock no-error.
        if avail b-t-crcpro then do:
            v-clog = yes.
            put stream v-out unformatted
                "<TD>" replace(replace(string(t-crcpro.rate[1] - b-t-crcpro.rate[1],"-zzz,zz9.99"),","," "),".",",") "</TD>" skip.
        end.
        else put stream v-out unformatted
            "<TD></TD>" skip.
    end.
    if v-clog = yes then put stream v-out unformatted
        "<TD>" replace(replace(string((t-crcpro.rate[1] - b-t-crcpro.rate[1]) * 100 / t-crcpro.rate[1],"-zzz,zzz,zzz,zzz,zzz,zz9.99"),","," "),".",",") "%</TD>" skip.
    else put stream v-out unformatted
        "<TD></TD>" skip.
    find first t-crcpro where t-crcpro.crc = t-crc.crc and t-crcpro.regdt > v-dt no-lock no-error.
    if avail t-crcpro then do:
        put stream v-out unformatted
            "<TD>" replace(replace(string(t-crcpro.rate[1],"-zzz,zz9.99"),","," "),".",",") "</TD>" skip.
    end.
    else put stream v-out unformatted
        "<TD></TD>" skip.
    put stream v-out unformatted
        "</B></TR>" skip.
end.
put stream v-out unformatted
    "</TABLE>" skip.

/*Обрабатываем данные полученные из отчета 7.4.3.5*/
for each t-valpozsv no-lock break by t-valpozsv.crc:
    if first-of(t-valpozsv.crc) then do:
        for each b-t-valpozsv where b-t-valpozsv.crc = t-valpozsv.crc no-lock break by b-t-valpozsv.dt:
            if first-of(b-t-valpozsv.dt) then do:
                create t-pozbal.
                t-pozbal.crc = t-valpozsv.crc.
                t-pozbal.dt  = b-t-valpozsv.dt.
                i = 0. v-sumtrebobal = 0. v-sumobyazbal = 0. v-sumtrebovnebal = 0. v-sumobyazvnebal = 0.
                for each b2-t-valpozsv where b2-t-valpozsv.crc = b-t-valpozsv.crc and b2-t-valpozsv.dt = b-t-valpozsv.dt
                no-lock use-index idxn:
                    i = i + 1.
                    if i >= 1 and i <= 6  then v-sumtrebobal = v-sumtrebobal + b2-t-valpozsv.val.
                    if i >= 7 and i <= 11 then v-sumobyazbal = v-sumobyazbal + b2-t-valpozsv.val.
                    if i = 12 then v-sumtrebovnebal = v-sumtrebovnebal + b2-t-valpozsv.val.
                    if i = 13 then v-sumobyazvnebal = v-sumobyazvnebal + b2-t-valpozsv.val.
                end.
                t-pozbal.balacc    = v-sumtrebobal - v-sumobyazbal.  /*По балансовым счетам*/
                t-pozbal.vnebalacc = v-sumtrebovnebal - v-sumobyazvnebal. /*Внебалансовым счетам*/
            end.
        end.
    end.
end.

put stream v-out unformatted
    "<P align=center style='font-size:12pt'><B>Позиция по</B></P>" skip.
put stream v-out unformatted
    "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""0"">" skip.
put stream v-out unformatted
    "<TR align=center color=blue style='font-size:10pt'><B>" skip
    "<TD>Наименование</TD>" skip
    "<TD>Балансовым счетам</TD>" skip
    "<TD>Внебалансовым счетам</TD>" skip
    "<TD colspan=2>Итого, тыс.тг.</TD>" skip
    "</B></TR>" skip.

nextcls1:
for each cls where cls.whn >= date(month(v-dt),1,year(v-dt)) and cls.whn <= v-dt no-lock break by cls.whn:
    if not Getdatests(cls.whn) then next nextcls1.

    create t-NettPos.
    t-NettPos.dt = cls.whn.
    for each crc where crc.crc > 1 and crc.crc <> 5 no-lock break by crc.crc:
        for each t-pozbal where t-pozbal.dt = cls.whn and t-pozbal.crc = crc.crc no-lock:
            t-NettPos.bal    = t-NettPos.bal    + t-pozbal.balacc.
            t-NettPos.vnebal = t-NettPos.vnebal + t-pozbal.vnebalacc.
            t-NettPos.sum    = t-NettPos.sum    + t-pozbal.balacc + t-pozbal.vnebalacc.
        end.
    end.
end.

empty temp-table t-nbrk.
for each crc where crc.crc > 1 and crc.crc <> 5 no-lock break by crc.crc:
    put stream v-out unformatted
        "<TR style='font-size:10pt'>" skip
        "<TD align=left>" crc.des "</TD>" skip.

    find t-pozbal where t-pozbal.dt = v-dt and t-pozbal.crc = crc.crc no-lock no-error.
    if avail t-pozbal then do:
        put stream v-out unformatted
            "<TD align=center>" replace(string(t-pozbal.balacc,"-zzz,zzz,zzz,zzz,zzz,zz9"),","," ") "</TD>" skip
            "<TD align=center>" replace(string(t-pozbal.vnebalacc,"-zzz,zzz,zzz,zzz,zzz,zz9"),","," ") "</TD>" skip
            "<TD align=center>" replace(string((t-pozbal.balacc + t-pozbal.vnebalacc),"-zzz,zzz,zzz,zzz,zzz,zz9"),","," ") "</TD>" skip.

        if t-pozbal.balacc + t-pozbal.vnebalacc > 0 then put stream v-out unformatted
            "<TD align=left>длинная</TD>" skip.
        else if t-pozbal.balacc + t-pozbal.vnebalacc < 0 then put stream v-out unformatted
            "<TD align=left>короткая</TD>" skip.
        else if t-pozbal.balacc + t-pozbal.vnebalacc = 0 then put stream v-out unformatted
            "<TD align=left>закрытая</TD>" skip.
    end.
    else do:
        put stream v-out unformatted
            "<TD align=center>0</TD>" skip
            "<TD align=center>0</TD>" skip
            "<TD align=center>0</TD>" skip
            "<TD align=left>закрытая</TD>" skip.
    end.
    put stream v-out unformatted
        "</TR>" skip.

    create t-nbrk.
    t-nbrk.crc = crc.crc.
    if avail crc then t-nbrk.crcdes = crc.des.
    if crc.crc = 2 then assign
    t-nbrk.reit = "AAA"
    t-nbrk.norm = 12.5
    t-nbrk.limi = "=C32" + "*" + "$F$27"
    t-nbrk.vnut = 6.25
    t-nbrk.vnli = "=E32" + "*" + "$F$27".
    if crc.crc = 3 then assign
    t-nbrk.reit = "евро"
    t-nbrk.norm = 12.5
    t-nbrk.limi = "=C33" + "*" + "$F$27"
    t-nbrk.vnut = 2.50
    t-nbrk.vnli = "=E33" + "*" + "$F$27".
    if crc.crc = 4 then assign
    t-nbrk.reit = "B+"
    t-nbrk.norm = 5.0
    t-nbrk.limi = "=C34" + "*" + "$F$27"
    t-nbrk.vnut = 2.50
    t-nbrk.vnli = "=E34" + "*" + "$F$27".
    if crc.crc = 6 then assign
    t-nbrk.reit = "AAA"
    t-nbrk.norm = 12.5
    t-nbrk.limi = "=C35" + "*" + "$F$27"
    t-nbrk.vnut = 2.50
    t-nbrk.vnli = "=E35" + "*" + "$F$27".
    if crc.crc = 7 then assign
    t-nbrk.reit = "AA+"
    t-nbrk.norm = 12.5
    t-nbrk.limi = "=C36" + "*" + "$F$27"
    t-nbrk.vnut = 2.50
    t-nbrk.vnli = "=E36" + "*" + "$F$27".
    if crc.crc = 8 then assign
    t-nbrk.reit = "AA+"
    t-nbrk.norm = 12.5
    t-nbrk.limi = "=C37" + "*" + "$F$27"
    t-nbrk.vnut = 2.50
    t-nbrk.vnli = "=E37" + "*" + "$F$27".
    if crc.crc = 9 then assign
    t-nbrk.reit = "AA+"
    t-nbrk.norm = 12.5
    t-nbrk.limi = "=C38" + "*" + "$F$27"
    t-nbrk.vnut = 2.50
    t-nbrk.vnli = "=E38" + "*" + "$F$27".
    if crc.crc = 10 then assign
    t-nbrk.reit = "BBB+"
    t-nbrk.norm = 5.0
    t-nbrk.limi = "=C39" + "*" + "$F$27"
    t-nbrk.vnut = 2.50
    t-nbrk.vnli = "=E39" + "*" + "$F$27".
    if crc.crc = 11 then assign
    t-nbrk.reit = "AAA"
    t-nbrk.norm = 12.5
    t-nbrk.limi = "=C40" + "*" + "$F$27"
    t-nbrk.vnut = 1.00
    t-nbrk.vnli = "=E40" + "*" + "$F$27".
end.

find t-NettPos where t-NettPos.dt = v-dt no-lock no-error.
if avail t-NettPos then do:
    put stream v-out unformatted
        "<TR color=blue style='font-size:10pt'>" skip
        "<TD>Валютная нетто- позиция</TD>" skip
        "<TD align=center>" replace(string(t-NettPos.bal,"-zzz,zzz,zzz,zzz,zzz,zz9"),","," ") "</TD>" skip
        "<TD align=center>" replace(string(t-NettPos.vnebal,"-zzz,zzz,zzz,zzz,zzz,zz9"),","," ") "</TD>" skip
        "<TD align=center>" replace(string(t-NettPos.sum,"-zzz,zzz,zzz,zzz,zzz,zz9"),","," ") "</TD>" skip.
    if t-NettPos.sum = 0 then put stream v-out unformatted
        "<TD>закрытая</TD>" skip.
    else if t-NettPos.sum > 0 then put stream v-out unformatted
        "<TD>длинная</TD>" skip.
    else if t-NettPos.sum < 0 then put stream v-out unformatted
        "<TD>короткая</TD>" skip.
    put stream v-out unformatted
        "</TR>" skip.
    put stream v-out unformatted
        "<TR style='font-size:10pt'>" skip
        "<TD>Валютная нетто- позиция, в %% к СК</TD>" skip
        "<TD align=center>=B21/$F$27</TD>" skip
        "<TD>=C21/$F$27</TD>" skip
        "<TD align=center>=D21/$F$27</TD>" skip
        "<TD></TD>" skip
        "</TR>" skip.
end.
put stream v-out unformatted
    "</TABLE>" skip.

/*Открытая валютная нетто-позиция*/
for each tgl no-lock break by tgl.dt:
    if first-of(tgl.dt) then do:
        create t-dohzaden.
        t-dohzaden.dt = tgl.dt.
        v-summa1 = 0. v-summa2 = 0.
        for each b-tgl where b-tgl.dt = tgl.dt no-lock:
            if lookup(substr(string(b-tgl.gl),1,4),v-gl1) > 0 then v-summa1 = v-summa1 + b-tgl.sumkzt.
            if lookup(substr(string(b-tgl.gl),1,4),v-gl2) > 0 then v-summa2 = v-summa2 + b-tgl.sumkzt.
        end.
        t-dohzaden.sumgod = round(v-summa1 / 1000,0) - round(v-summa2 / 1000,0).
    end.
end.

put stream v-out unformatted
    "<P align=center color=blue style='font-size:12pt'><B>Лимиты открытой валютной позиции</B></P>" skip.
put stream v-out unformatted
    "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""0"">" skip.
put stream v-out unformatted
    "<TR style='font-size:10pt'>" skip
    "<TD colspan=4></TD>" skip
    "<TD></TD>" skip
    "<TD align=right>тыс.тг.</TD>" skip
    "</TR>" skip
    "<TR color=blue style='font-size:10pt'><B>" skip
    "<TD colspan=4 align=left>Собственный Капитал на</TD>" skip
    "<TD align=center>" string(date(month(v-dt),1,year(v-dt)),"99.99.9999") "</TD>" skip
    "<TD></TD>" skip
    "</B></TR>" skip
    "<TR style='font-size:10pt'>"
    "<TD colspan=4></TD>" skip
    "<TD align=center color=dark>за день</TD>" skip
    "<TD align=center color=dark>за год</TD>" skip
    "</TR>" skip
    "<TR style='font-size:10pt'>"
    "<TD colspan=4>Доходы / Расходы от переоценки нетто - позиции</TD>" skip.

find last t-dohzaden where t-dohzaden.dt <= v-dt no-lock no-error.
if avail t-dohzaden then do:
    find last b-t-dohzaden where b-t-dohzaden.dt < v-dt no-lock no-error.
    if avail b-t-dohzaden then do:
        put stream v-out unformatted
        "<TD align=center>" replace(string(t-dohzaden.sumgod - b-t-dohzaden.sumgod,"-zzz,zzz,zzz,zzz,zzz,zz9"),","," ") "</TD>" skip.
    end.
    else put stream v-out unformatted
        "<TD align=center></TD>" skip.
    put stream v-out unformatted
        "<TD align=center>" replace(string(t-dohzaden.sumgod,"-zzz,zzz,zzz,zzz,zzz,zz9"),","," ") "</TD>" skip.
end.
else put stream v-out unformatted
    "<TD align=center></TD>" skip
    "<TD align=center></TD>" skip.
put stream v-out unformatted
    "</TR>" skip.

put stream v-out unformatted
    "<TR color=blue>" skip
    "<TD colspan=5 height=""30%""></TD>" skip
    "</TR>" skip
    "<TR align=center style='font-size:10pt'><B>" skip
    "<TD>Рейтинг</TD>" skip
    "<TD>Валюта</TD>" skip
    "<TD>Норматив НБРК</TD>" skip
    "<TD>Лимит позиции НБРК</TD>" skip
    "<TD>Внутренний норматив</TD>" skip
    "<TD>Внутренний Лимит позиции</TD>" skip
    "</B></TR>" skip.

for each t-nbrk no-lock break by t-nbrk.crc:
    put stream v-out unformatted
        "<TR style='font-size:10pt'>" skip
        "<TD align=center>" t-nbrk.reit "</TD>" skip
        "<TD align=left>" t-nbrk.crcdes "</TD>" skip
        "<TD align=center>" replace(string(t-nbrk.norm),".",",") "%</TD>" skip
        "<TD align=center>" t-nbrk.limi "</TD>" skip
        "<TD align=center>" replace(string(t-nbrk.vnut),".",",") "%</TD>" skip
        "<TD align=center>" t-nbrk.vnli "</TD>" skip
        "</TR>" skip.
end.
put stream v-out unformatted
    "<TR color=blue style='font-size:10pt'><B>" skip
    "<TD>Валютная нетто - позиция</TD>" skip
    "<TD></TD>" skip
    "<TD align=center>25%</TD>" skip
    "<TD align=center>=C41 * $F$27</TD>" skip
    "<TD align=center>10%</TD>" skip
    "<TD align=center>=E41 * $F$27</TD>" skip
    "</B></TR>" skip.
put stream v-out unformatted
    "</TABLE>" skip.

{html-end.i "stream v-out"}

output stream v-out  close.

{html-title.i &stream = "stream v-out2"}

for each crc where crc.crc > 1 and crc.crc <> 5 no-lock break by crc.crc:
        put stream v-out2 unformatted
            "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""0"">" skip.

        put stream v-out2 unformatted
            "<TR align=center style='font-size:12pt;color:blue'><B>" skip
            "<TD colspan=3>" crc.code "</TD>" skip
            "</B></TR>" skip
            "<TR style='font-size:10pt'><B>" skip
            "<TD>Дата</TD>" skip
            "<TD align=left>Открытая позиция « " crc.des " »</TD>" skip
            "<TD align=center>Курсы</TD>" skip
            "</B></TR>" skip.
        nextcls2:
        for each cls where cls.whn >= date(month(v-dt),1,year(v-dt)) and cls.whn <= v-dt no-lock break by cls.whn:
            if not Getdatests(cls.whn) then next nextcls2.
            put stream v-out2 unformatted
                "<TR align=center style='font-size:10pt'>" skip
                "<TD>" string(cls.whn,"99.99.9999") "</TD>" skip.
            find b2-t-pozbal where b2-t-pozbal.crc = crc.crc and b2-t-pozbal.dt = cls.whn no-lock no-error.
            if avail b2-t-pozbal then do:
                put stream v-out2 unformatted
                    "<TD>" replace(string(b2-t-pozbal.balacc + b2-t-pozbal.vnebalacc,"-zzz,zzz,zzz,zzz,zzz,zz9"),","," ") "</TD>" skip.
            end.
            else put stream v-out2 unformatted
                "<TD>0</TD>" skip.
            find last t-crcpro where t-crcpro.crc = crc.crc and t-crcpro.regdt <= cls.whn no-lock no-error.
            if avail t-crcpro then put stream v-out2 unformatted
                "<TD>" replace(replace(string(t-crcpro.rate[1],"zzz,zz9.99"),","," "),".",",") "</TD>" skip.
            else put stream v-out2 unformatted
                "<TD></TD>" skip.
            put stream v-out2 unformatted
                "</TR>" skip.
        end.

        put stream v-out2 unformatted
            "</TABLE>" skip.
end.

/*---------------------------------------------------------------------*/
function VPDays returns deci(input dt as date).
    def var v-sum  as deci.
    def var v-sum1 as deci.
    def var v-sum2 as deci.

    v-sum1 = 0. v-sum2 = 0.
    find b-t-dohzaden where b-t-dohzaden.dt = dt no-lock no-error.
    if avail b-t-dohzaden then v-sum1 = b-t-dohzaden.sumgod.

    find last b-t-dohzaden where b-t-dohzaden.dt < dt no-lock no-error.
    if avail b-t-dohzaden then v-sum2 = b-t-dohzaden.sumgod.

    v-sum = v-sum1 - v-sum2.

    return v-sum.
end function.
/*---------------------------------------------------------------------*/

put stream v-out2 unformatted
    "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""0"">" skip.

put stream v-out2 unformatted
    "<TR align=center style='font-size:10pt'>" skip
    "<TD>Дата</TD>" skip
    "<TD>Доходы/Расходы от переоценки за день</TD>" skip
    "<TD>нетто-позиция</TD>" skip
    "</TR>" skip.

nextcls3:
for each cls where cls.whn >= date(month(v-dt),1,year(v-dt)) and cls.whn <= v-dt no-lock break by cls.whn:
    if not Getdatests(cls.whn) then next nextcls3.
    put stream v-out2 unformatted
        "<TR align=center style='font-size:10pt'>" skip.
    find first t-dohzaden where t-dohzaden.dt = cls.whn no-lock no-error.
    if avail t-dohzaden then do:
        put stream v-out2 unformatted
            "<TD>" string(t-dohzaden.dt,"99.99.9999") "</TD>" skip
            "<TD>" replace(string(VPDays(t-dohzaden.dt),"-zzz,zzz,zzz,zzz,zzz,zz9"),","," ") "</TD>" skip.
    end.
    else put stream v-out2 unformatted
        "<TD></TD>" skip
        "<TD></TD>" skip.
    find t-NettPos where t-NettPos.dt = cls.whn no-lock no-error.
    if avail t-NettPos then do:
        put stream v-out2 unformatted
            "<TD>" replace(string(t-NettPos.sum,"-zzz,zzz,zzz,zzz,zzz,zz9"),","," ") "</TD>" skip.
    end.
    else put stream v-out2 unformatted
        "<TD></TD>" skip.
    put stream v-out2 unformatted
        "</TR>" skip.
end.

put stream v-out2 unformatted
    "</TABLE>" skip.

{html-end.i "stream v-out2"}

output stream v-out2 close.

unix silent cptwin value(v-file)  excel.
unix silent cptwin value(v-file2) excel.

return.








