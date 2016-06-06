/* repOI.p
 * MODULE

 * DESCRIPTION
        Основные источники привлеченных денег
 * RUN

 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        27/12/2012 Luiza
 * BASES
        BANK COMM
 * CHANGES
            14/01/2013 Luiza - изменила сбор данных в табл wrk1 (если нет иин идентифицируем по названию)
*/
{mainhead.i}

def new shared var dt1 as date no-undo.
def new shared var v-fil-cnt as char.
def new shared var v-fil-int as int init 0.
def new shared var v-ful as logic format "да/нет" no-undo.

def stream v-out.
def stream v-ob.
def var prname as char.
def new shared var v-select1 as int no-undo.
def var v-ful1 as int no-undo.

def var v_bin as logi init no.
find first sysc where sysc.sysc = 'bin' no-lock no-error.
if avail sysc then v_bin = sysc.loval.

displ dt1 label   " На дату " format "99/99/9999" validate(dt1 < g-today, "Некорректная дата!") skip
      v-ful label " С расшифровкой" skip
with side-label row 4 centered frame dat.

update dt1 with frame dat.
update v-ful with frame dat.

v-select1 = 0.
def var v-raz as char  no-undo.

run sel2 (" Выберите ", "1. В тыс.тенге |2. В тенге |3. ВЫХОД ", output v-select1).
if keyfunction (lastkey) = "end-error" or v-select1 = 3 then return.
if v-select1 = 1 then v-raz = "  в тыс.тенге". else v-raz = "  в тенге".

def temp-table dif  /* для расчета расхождений  */
      field gl like gl.gl
      field crc like crc.crc
      field sum_gl as deci
      field sum_gl_kzt as deci
      field sum_lon as deci
      index gl_idx is primary gl
      index glcrc_idx is unique gl crc.


define new shared temp-table tgl
    field txb    as character
    field gl     as integer
    field gl4 as integer
    field gl7 as integer
    field gl-des  as character
    field crc   as integer
    field sum  as decimal     format "->>>>>>>>>>>>>>9.99"
    field sum-val as decimal     format "->>>>>>>>>>>>>>9.99"
    field type as character
    field sub-type as character
    field totlev as integer
    field totgl  as integer
    field level as integer
    field code as character
    field grp as integer
    field acc as character
    field acc-des as character
    field geo as character
    field odt as date
    field cdt as date
    field perc as decimal
    field prod as char
    field cif as char
    field iin as char
    field otr as char
    index tgl-id1 is primary gl7 .


define new shared temp-table t-salde no-undo
    field cif as char
    field cl as char
    field iin as char     format "999999999999"
    field otr as char
    field secek as char
    field gl as int
    field gl7 as int
    field acc as char
    field crc as int
    field dtop as date
    field dtcl as date
    field pr as decim
    field sum1 as decim
    field sum1-val as decim
    field sum2 as decim
    field sum2-val as decim
    field sum3 as decim
    field sum3-val as decim
    field sum4 as decim
    field sum4-val as decim
    field sum5 as decim
    field sum5-val as decim
    field sum6 as decim
    field sum6-val as decim
    field sum7 as decim
    field sum7-val as decim
    field txb as char
    field txbname as char
    field sub as char
    field poz as int
    index ind is primary  txbname cif.

define temp-table wrk1 no-undo
    field cif as char
    field cl as char
    field iin as char
    field otr as char
    field sum1 as decim
    field sum2 as decim
    field sum3 as decim
    field sum4 as decim
    field sum5 as decim
    field sum6 as decim
    field sum7 as decim
    index ind  is primary  sum7 DESCENDING .

define new shared variable v-gldate as date.
def new shared var v-gl1 as int no-undo.
def new shared var v-gl2 as int no-undo.
def new shared var v-gl-cl as int no-undo.
def var RepName as char.
def var RepPath as char init "/data/reports/array/".

define new shared temp-table wrk no-undo
    field gl as char
    field num as int.

create wrk.
wrk.num = 5.
wrk.gl = "2011,2012,2013,2014,2203,2204". /* Корреспондентские/ текущие счета */
create wrk.
wrk.num = 6.
wrk.gl = "2021,2022,2023,2024,2205,2211,2224". /* Вклады до востребования */
create wrk.
wrk.num = 7.
wrk.gl = "2133,2136,2137,2138,2208,2219,2235,2236". /* Условный вклад */
create wrk.
wrk.num = 8.
wrk.gl = "2121,2122,2123,2124,2125,2127,2128,2129,2131,2135,2139,2140,2206,2207,2213,2215,2217,2222,2223,2226". /* Срочный вклад */
create wrk.
wrk.num = 9.
wrk.gl = "2301,2303,2304,2305,2306". /* Облигации и другие ценные бумаги  */
create wrk.
wrk.num = 10.
wrk.gl = "2034,2035,2036,2037,2038,2041,2042,2044,2045,2046,2047,2048,2051,2052,2054,2055,2056,2057,2058,2059,2064,2065,2066,2067,2068,2069,2070,2111,2112,2113,2402". /* Займы привлеченные */

function FileExist returns log (input v-name as char).
 def var v-result as char init "".
 input through value ("cat " + v-name + " &>/dev/null || (NO)").
 repeat:
   import unformatted v-result.
 end.
 if v-result = "" then return true.
 else return false.
end function.

/* формирование рабочей таблицы */
    def var lst as char.
    def var v-grp as char.
    def var j as int.
    def var i as int.
    displ  "Ждите, формир-ся данные " format "x(70)" with row 10 overlay frame ww .
    pause 0.
    define new shared temp-table wgl no-undo
        field gl     as integer /*like gl.gl*/
        field des as character
        field lev as integer
        field subled as character /*like gl.subled*/
        field type   as character /*like gl.type*/
        field code as char
        field grp as int
        field num as int
        index wgl-idx1 is unique primary gl
        index wgl-idx2  subled.

    for each wrk.
        lst = wrk.gl.
        do i = 1 to num-entries(lst):
            v-grp = entry(i,lst).
            for each gl where gl.totlev = 1 and gl.totgl <> 0 and string(gl.gl) begins v-grp no-lock:
                create wgl.
                wgl.num = wrk.num.
                wgl.gl = gl.gl.
                wgl.subled = gl.subled.
                wgl.des = gl.des.
                wgl.lev = gl.level.
                wgl.type = gl.type.
                wgl.code = gl.code.
                wgl.grp = gl.grp.
            end.
        end.
    end. /* for each wrk. */
v-gldate = dt1 - 1.
for each comm.txb where comm.txb.consolid no-lock:
    if connected ("txb") then disconnect "txb".
    connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
    run repOItxb.
end.
if connected ("txb")  then disconnect "txb".
/*----расшифровка-----------------------------------------------------------------------------------------------*/
    for each wrk.
        lst = wrk.gl.
        do j = 1 to num-entries(lst):
            v-grp = entry(j,lst).
            for each tgl where string(tgl.gl) begins v-grp no-lock.
                create t-salde.
                t-salde.cif  = tgl.cif.
                t-salde.cl  = tgl.acc-des.
                t-salde.iin = tgl.iin.
                t-salde.otr = tgl.otr.
                t-salde.secek  = substring(string(tgl.gl7),6,1).
                t-salde.gl  = tgl.gl.
                t-salde.gl7  = tgl.gl7.
                t-salde.acc  = tgl.acc.
                t-salde.crc  = tgl.crc.
                t-salde.dtop  = tgl.odt.
                t-salde.dtcl  = tgl.cdt.
                t-salde.pr  = tgl.perc.
                case wrk.num:
                    when 5 then do: t-salde.sum1-val  = tgl.sum-val. t-salde.sum1  = tgl.sum. end.
                    when 6 then do: t-salde.sum2-val  = tgl.sum-val. t-salde.sum2  = tgl.sum. end.
                    when 7 then do: t-salde.sum3-val  = tgl.sum-val. t-salde.sum3  = tgl.sum. end.
                    when 8 then do: t-salde.sum4-val  = tgl.sum-val. t-salde.sum4  = tgl.sum. end.
                    when 9 then do: t-salde.sum5-val  = tgl.sum-val. t-salde.sum5  = tgl.sum. end.
                    when 10 then do: t-salde.sum6-val  = tgl.sum-val. t-salde.sum6  = tgl.sum. end.
                end case.
                find first txb where txb.bank = tgl.txb no-lock.
                if available txb then t-salde.txbname = txb.info.
                t-salde.sub  = tgl.sub-type.
                t-salde.poz  = wrk.num.
                if tgl.acc = "KZ58470172402A082100"  then do:
                    /*find first wrk1 where wrk1.cif = "T14402" no-error.*/ /* для maglink */
                    /*if v_bin then find first wrk1 where wrk1.iin = "110650021704" no-error. else find first wrk1 where wrk1.iin = "600900645161" no-error.*/
                    find first wrk1 where wrk1.cl = "Компания Maglink Limited" no-error.
                    if not available wrk1 then do:
                        create wrk1.
                        wrk1.cif  = "T14402".
                        wrk1.cl  = "Компания Maglink Limited".
                        if v_bin then wrk1.iin = "110650021704". else wrk1.iin = "600900645161".
                        wrk1.otr = "64".
                    end.
                end.
                else do:
                    if tgl.acc = "KZ10470172402A081800"  then do:
                        /*find first wrk1 where wrk1.cif = "T13662" no-error.*/ /* для Verny */
                        if v_bin then find first wrk1 where wrk1.iin = "060740008050" no-error. else find first wrk1 where wrk1.iin = "600900574763" no-error.
                        if not available wrk1 then do:
                            create wrk1.
                            wrk1.cif  = "T13662".
                            wrk1.cl  = 'ТОО "Verny Investments Holding"'.
                            if v_bin then wrk1.iin = "060740008050". else wrk1.iin = "600900574763".
                            wrk1.otr = "66".
                        end.
                    end.
                    else do:
                        /* если sub cif или lon собираем по иин */
                        if tgl.sub-type = "CIF" or tgl.sub-type = "LON"  then do:
                            if tgl.iin <> "" then find first wrk1 where wrk1.iin = tgl.iin no-error.
                            else find first wrk1 where wrk1.cl = tgl.acc-des no-error.
                            if not available wrk1 then do:
                                create wrk1.
                                wrk1.cif  = tgl.cif.
                                wrk1.cl  = tgl.acc-des.
                                wrk1.iin = tgl.iin.
                                wrk1.otr = tgl.otr.
                            end.
                        end. /* if tgl.sub-type = "CIF" or tgl.sub-type = "LON" */
                        else do: /* если sub arp или др  */
                            create wrk1.
                            wrk1.cif  = tgl.cif.
                            wrk1.cl  = tgl.acc-des.
                            wrk1.iin = tgl.iin.
                            wrk1.otr = tgl.otr.
                        end.
                    end.
                end.

                wrk1.sum7 = wrk1.sum7 + tgl.sum.
                case wrk.num:
                    when 5 then wrk1.sum1 = wrk1.sum1 + tgl.sum.
                    when 6 then wrk1.sum2 = wrk1.sum2 + tgl.sum.
                    when 7 then wrk1.sum3 = wrk1.sum3 + tgl.sum.
                    when 8 then wrk1.sum4 = wrk1.sum4 + tgl.sum.
                    when 9 then wrk1.sum5 = wrk1.sum5 + tgl.sum.
                    when 10 then wrk1.sum6 = wrk1.sum6 + tgl.sum.
                end case.
            end.
        end.
    end.

   /* if v-select1 = 1 then do:
        for each wrk1.
            if wrk1.sum1 <> 0 then wrk1.sum1 = round((wrk1.sum1 / 1000),0).
            if wrk1.sum2 <> 0 then wrk1.sum2 = round((wrk1.sum2 / 1000),0).
            if wrk1.sum3 <> 0 then wrk1.sum3 = round((wrk1.sum3 / 1000),0).
            if wrk1.sum4 <> 0 then wrk1.sum4 = round((wrk1.sum4 / 1000),0).
            if wrk1.sum5 <> 0 then wrk1.sum5 = round((wrk1.sum5 / 1000),0).
            if wrk1.sum6 <> 0 then wrk1.sum6 = round((wrk1.sum6 / 1000),0).
            if wrk1.sum7 <> 0 then wrk1.sum7 = round((wrk1.sum7 / 1000),0).
        end.
    end.*/
/*------------------------------------------------------------------------------------------------------------------*/
def stream v-out.
output stream v-out to struc.html.
    put stream v-out unformatted "<html><head><title>METROCOMBANK</title>"
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    put stream v-out unformatted  "<table border=""0"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
    put stream v-out unformatted
         "<tr><TD> </TD>" skip
         "<TD> </TD>" skip
         "<TD> </TD>" skip
         "<TD> </TD>" skip
         "<TD> </TD>" skip
         "<TD> </TD>" skip
         "<tr> <TD colspan=10 align=right > Приложение 16 к Инструкции о перечне, формах и сроках представления регуляторной <br> отчетности банками второго уровня Республики Казахстан  </TD> </tr>" skip
         "<tr> <TD colspan=10 align=center > Основные источники привлеченных денег  </TD> </tr>" skip
         "<tr> <TD colspan=10 align=center > АО 'ForteBank'  </TD> </tr>" skip
         "<tr> <TD colspan=10 align=center > (наименование банка)  </TD> </tr>" skip
         "<tr> <TD colspan=10 align=center > по состоянию на " dt1  " </TD> </tr>" skip
         "<tr>  </tr>" skip
         "<tr>  </tr>" skip
         "<tr> <TD colspan=10 align=right >"  v-raz  "</TD> </tr>" skip
         "</table>" skip.

    put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
    put stream v-out unformatted
         "<tr><TD align=center > № п/п </TD>" skip
         "<TD align=center > Наименование депозитора (кредитора) </TD>" skip
         "<TD align=center > Регистрационный номер <br> налогоплательщика (РНН), <br> бизнес-идентификационный номер <br> (для юридического лица) <br> или индивидуальный  </TD>" skip
         "<TD align=center > Код отрасли </TD>" skip
         "<TD align=center > Корреспондентские/ <br> текущие счета </TD>" skip
         "<TD align=center > Вклады <br> до востребованиях </TD>" skip
         "<TD align=center > Условный <br> вклад </TD>" skip
         "<TD align=center > Срочный <br> вклад </TD>" skip
         "<TD align=center > Облигации и другие <br> ценные бумаги </TD>" skip
         "<TD align=center > Займы <br> привлеченные </TD>" skip
         "<TD align=center > Всего </TD></tr>" skip
         "</tr>" skip.
    put stream v-out unformatted
         "<tr><TD align=center > 1 </TD>" skip
         "<TD align=center > 2 </TD>" skip
         "<TD align=center > 3 </TD>" skip
         "<TD align=center > 4 </TD>" skip
         "<TD align=center > 5 </TD>" skip
         "<TD align=center > 6 </TD>" skip
         "<TD align=center > 7 </TD>" skip
         "<TD align=center > 8 </TD>" skip
         "<TD align=center > 9 </TD>" skip
         "<TD align=center > 10 </TD>" skip
         "<TD align=center > 11 </TD></tr>" skip
         "</tr>" skip.

    i = 0.
    for each  wrk1 use-index ind.
        i = i + 1.
        if i > 25 then leave.
        put stream v-out unformatted
        "<tr> <td> " i "</td>" skip
        "<td> "  wrk1.cl "</td>" skip
        "<td> &nbsp;"  wrk1.iin "</td>" skip
        "<td> "  wrk1.otr "</td>" skip.
        if v-select1 = 1 then do:
            put stream v-out unformatted "<td> " round(( wrk1.sum1 / 1000),0) "</td>" skip
            "<td> " round(( wrk1.sum2 / 1000),0) "</td>" skip
            "<td> " round(( wrk1.sum3 / 1000),0) "</td>" skip
            "<td> " round(( wrk1.sum4 / 1000),0) "</td>" skip
            "<td> " round(( wrk1.sum5 / 1000),0) "</td>" skip
            "<td> " round(( wrk1.sum6 / 1000),0) "</td>" skip
            "<td> " round(( wrk1.sum7 / 1000),0) "</td>" skip.
        end.
        else do:
            put stream v-out unformatted "<td> " replace(trim(string( wrk1.sum1,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
            "<td> " replace(trim(string( wrk1.sum2,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
            "<td> " replace(trim(string( wrk1.sum3,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
            "<td> " replace(trim(string( wrk1.sum4,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
            "<td> " replace(trim(string( wrk1.sum5,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
            "<td> " replace(trim(string( wrk1.sum6,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
            "<td> " replace(trim(string( wrk1.sum7,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip.
        end.
        put stream v-out unformatted "</tr>" skip.
    end.
put stream v-out unformatted "</table>" skip.
output stream v-out close.
unix silent cptwin struc.html excel.exe.
pause 0.

if v-ful then do:
    output stream v-ob to ob.html.
    put stream v-ob unformatted "<html><head><title>METROCOMBANK</title>"
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    put stream v-ob unformatted  "<h3> Расшифровка к отчету Основные источники привлеченных денег по состоянию на " dt1  "</h3>" skip.

    put stream v-ob unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
    put stream v-ob unformatted
         "<tr><TD rowspan=2 align=center > Филиал </TD>" skip
         "<TD rowspan=2 align=center > Код клиента </TD>" skip
         "<TD rowspan=2 align=center > Наименование депозитора (кредитора) </TD>" skip
         "<TD rowspan=2 align=center > РНН/БИН/ИИН  </TD>" skip
         "<TD rowspan=2 align=center > Код отрасли </TD>" skip
         "<TD rowspan=2 align=center > Признак юр/физ </TD>" skip
         "<TD rowspan=2 align=center > Счет ГК </TD>" skip
         "<TD rowspan=2 align=center > Балансовый счет </TD>" skip
         "<TD rowspan=2 align=center > Лицевой счет </TD>" skip
         "<TD rowspan=2 align=center > Вид валюты </TD>" skip
         "<TD rowspan=2 align=center > Дата открытия  </TD>" skip
         "<TD rowspan=2 align=center > Дата закрытия </TD>" skip
         "<TD rowspan=2 align=center > Процентная ставка </TD>" skip
         "<TD colspan=2 align=center > Корреспондентские/ <br> текущие счета </TD>" skip
         "<TD colspan=2 align=center > Вклады <br> до востребованиях </TD>" skip
         "<TD colspan=2 align=center > Условный <br> вклад </TD>" skip
         "<TD colspan=2 align=center > Срочный <br> вклад </TD>" skip
         "<TD colspan=2 align=center > Облигации и другие <br> ценные бумаги </TD>" skip
         "<TD colspan=2 align=center > Займы <br> привлеченные </TD>" skip
         "<TD rowspan=2 align=center > столб </TD></tr>" skip
         "</tr>" skip
        "<tr><TD align=center > в валюте </TD>" skip
        "<TD align=center > в тенге </TD>" skip
        "<TD align=center > в валюте </TD>" skip
        "<TD align=center > в тенге </TD>" skip
        "<TD align=center > в валюте </TD>" skip
        "<TD align=center > в тенге </TD>" skip
        "<TD align=center > в валюте </TD>" skip
        "<TD align=center > в тенге </TD>" skip
        "<TD align=center > в валюте </TD>" skip
        "<TD align=center > в тенге </TD>" skip
        "<TD align=center > в валюте </TD>" skip
        "<TD align=center > в тенге </TD>" skip
         "</tr>" skip.

    for each t-salde use-index ind.
        put stream v-ob unformatted
        "<tr> <td> " t-salde.txbname "</td>" skip
        "<td> " t-salde.cif "</td>" skip
        "<td> " t-salde.cl "</td>" skip
        "<td> &nbsp;" t-salde.iin "</td>" skip
        "<td> " t-salde.otr "</td>" skip
        "<td> " t-salde.secek "</td>" skip
        "<td> " t-salde.gl "</td>" skip
        "<td> " t-salde.gl7 "</td>" skip
        "<td> " t-salde.acc "</td>" skip
        "<td> " t-salde.crc "</td>" skip
        "<td> " t-salde.dtop "</td>" skip
        "<td> " t-salde.dtcl "</td>" skip
        "<td> " t-salde.pr "</td>" skip
        "<td> " replace(trim(string(t-salde.sum1-val,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td> " replace(trim(string(t-salde.sum1,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td> " replace(trim(string(t-salde.sum2-val,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td> " replace(trim(string(t-salde.sum2,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td> " replace(trim(string(t-salde.sum3-val,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td> " replace(trim(string(t-salde.sum3,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td> " replace(trim(string(t-salde.sum4-val,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td> " replace(trim(string(t-salde.sum4,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td> " replace(trim(string(t-salde.sum5-val,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td> " replace(trim(string(t-salde.sum5,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td> " replace(trim(string(t-salde.sum6-val,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td> " replace(trim(string(t-salde.sum6,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td> " t-salde.poz "</td>" skip
        "</tr>" skip.
    end.
    put stream v-ob unformatted "</table>" skip.
    output stream v-ob close.
    unix silent value("cptwin ob.html excel").
    hide message no-pause.
end.


