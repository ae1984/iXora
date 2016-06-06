/* repmarj.p
 * MODULE
        Бухгалтерский отчет
 * DESCRIPTION
        Отчет Анализ процентной маржи в тенге за период в сравнении с периодом с начала года.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        12.18.8
 * AUTHOR
        01.04.2011 Luiza
 * BASES
        BANK COMM
 * CHANGES
        14.07.2011 damir - вызывается 2 программами, rep3.p и repmarj0.p. добавлены входные параметры.
        26.10.2011 damir - устранил мелкие ошибки.
        21.02.2012 damir - Отчет работал не правильно, почти полностью переделал. Т.З. № 1283.
        01.02.2012 damir - замена отчета на EXCEL.
        15.03.2012 id00810 - название банка из sysc
        25/04/2012 evseev  - rebranding. разбранчевка с учетом банк-мко.
*/

/*{mainhead.i}*/
{global.i}

def input parameter v-option      as char.
def input parameter v-downdate    as date.
def input parameter v-update      as date.
def output parameter vfname       as char init "tttt.xls".
def input-output parameter vres   as logi.

def new shared var v-fil-cnt as char.
def new shared var v-fil-int as inte init 0.
def new shared var dt1       as date.
def new shared var dt2       as date.
def new shared var dt        as date.

def var v-dt2 as date no-undo.
def new shared var cntd as int no-undo.
def new shared var cnty as int no-undo.
def var i as integer.
def var v-sumt as deci no-undo.  /* сальдо за период  */
def var v-sumy as deci no-undo.  /* сальдо с начала года  */
def var v-rast as deci no-undo.  /* расход/доход за период  */
def var v-rasy as deci no-undo.  /* расход/доход с начала года  */
def var v-sumt1 as deci no-undo.  /* сальдо за период  */
def var v-sumy1 as deci no-undo.  /* сальдо с начала года  */
def var v-rast1 as deci no-undo.  /* расход/доход за период  */
def var v-rasy1 as deci no-undo.  /* расход/доход с начала года  */
def var tot-sumt as deci no-undo.
def var tot-sumy as deci no-undo.
def var tot-rast as deci no-undo.
def var tot-rasy as deci no-undo.
def var tot-sumt1 as deci no-undo.
def var tot-sumy1 as deci no-undo.
def var tot-rast1 as deci no-undo.
def var tot-rasy1 as deci no-undo.
def var akt-sumt as deci no-undo.
def var akt-sumy as deci no-undo.
def var akt-rast as deci no-undo.
def var akt-rasy as deci no-undo.
def var ob-sumt as deci no-undo.
def var ob-sumy as deci no-undo.
def var ob-rast as deci no-undo.
def var ob-rasy as deci no-undo.
def var akt-sumt1 as deci no-undo.
def var akt-sumy1 as deci no-undo.
def var akt-rast1 as deci no-undo.
def var akt-rasy1 as deci no-undo.
def var ob-sumt1 as deci no-undo.
def var ob-sumy1 as deci no-undo.
def var ob-rast1 as deci no-undo.
def var ob-rasy1 as deci no-undo.
def stream v-out.
message  "Ждите идет подготовка данных для отчета ".
define new shared temp-table wrk no-undo
    field p         as inte
    field pp        as inte
    field nname     as char
    field av_saldo  as deci
    field av_saldo1 as deci
    field av_saldo2 as deci
    field av_saldo3 as deci
    field income    as deci
    field an_rate   as deci
    field income1   as deci
    field an_rate1  as deci
    field income3   as deci
    field an_rate3  as deci
    index ind1 is primary p.

define new shared temp-table wrk1 no-undo
    field pr        as logi
    field p         as inte
    field pp        as inte
    field nname     as char
    field av_saldo  as deci
    field av_saldo1 as deci
    field av_saldo2 as deci
    field av_saldo3 as deci
    field income    as deci
    field an_rate   as deci
    field income1   as deci
    field an_rate1  as deci
    field income3   as deci
    field an_rate3  as deci
    index ind2 is primary p.

define new shared temp-table wrk2 no-undo
    field p         as inte
    field pp        as inte
    field nname     as char
    field av_saldo  as deci
    field av_saldo1 as deci
    field av_saldo2 as deci
    field av_saldo3 as deci
    field income    as deci
    field an_rate   as deci
    field income1   as deci
    field an_rate1  as deci
    field income3   as deci
    field an_rate3  as deci
   index ind1 is primary p.

define new shared temp-table wrk3 no-undo
    field pr        as logi
    field p         as inte
    field pp        as inte
    field nname     as char
    field av_saldo  as deci
    field av_saldo1 as deci
    field av_saldo2 as deci
    field av_saldo3 as deci
    field income    as deci
    field an_rate   as deci
    field income1   as deci
    field an_rate1  as deci
    field income3   as deci
    field an_rate3  as deci
    index ind2 is primary p.

define new shared temp-table wrk4 no-undo
    field pr        as logi
    field p         as inte
    field pp        as inte
    field nname     as char
    field av_saldo  as deci
    field av_saldo1 as deci
    field av_saldo2 as deci
    field av_saldo3 as deci
    field income    as deci
    field an_rate   as deci
    field income1   as deci
    field an_rate1  as deci
    field income3   as deci
    field an_rate3  as deci
    index ind2 is primary p.

def new shared temp-table t-period no-undo
  field dt as date
  index idx is primary dt.

def new shared temp-table g-period no-undo
  field dt as date
  index idx is primary dt.

def new shared temp-table ch no-undo
  field p as int
  field fl as char
  field gl as int
  field acc as char
  field crc as int
  field glr as int
  field lev as int
  index idx is primary p fl gl.

def new shared temp-table ch_glr no-undo
  field p as int
  field fl as char
  field gl as int
  field acc as char
  field crc as int
  field glr as int
  index idx is primary p glr.

def new shared temp-table ch_ob no-undo
  field p as int
  field fl as char
  field gl as int
  field acc as char
  field crc as int
  field glr as int
  index idx is primary p fl gl.

/*для комисс  счета 4429  */
def new shared temp-table com no-undo
    field glcom as int
    index idx is primary glcom.

def new shared temp-table akt_saldo no-undo
    field pr    as logi
    field p     as inte
    field fl    as char format "x(3)"
    field nname as char
    field ch    as char
    field glr   as char
    index idx1 is primary p.

def var v-aktobyaz11 as deci.
def var v-aktobyaz12 as deci.
def var v-aktobyaz21 as deci.
def var v-aktobyaz22 as deci.
def var v-aktobyaz31 as deci.
def var v-aktobyaz32 as deci.
def var v-aktobyaz41 as deci.
def var v-aktobyaz42 as deci.
def var v-aktobyaz51 as deci.
def var v-aktobyaz52 as deci.
def var v-aktobyaz61 as deci.
def var v-aktobyaz62 as deci.

def var v-godmarj11 as deci.
def var v-godmarj12 as deci.
def var v-godmarj21 as deci.
def var v-godmarj22 as deci.

def var v-permarj1 as deci.
def var v-permarj2 as deci.

def var v-aktgl1  as char init "".
def var v-aktgl2  as char init "".
def var v-aktgl3  as char init "".
def var v-aktgl4  as char init "".
def var v-aktgl5  as char init "".
def var v-aktgl6  as char init "".
def new shared var v-aktglr1 as char init "".
def new shared var v-aktglr2 as char init "".
def new shared var v-aktglr3 as char init "".
def new shared var v-aktglr4 as char init "".
def new shared var v-aktglr5 as char init "".
def new shared var v-aktglr6 as char init "".

/*-------------------АКТИВЫ--------------------------------------------------------------------------*/
gl:
for each gl no-lock use-index gl:
    if (trim(string(gl.gl)) begins "110") or (trim(string(gl.gl)) begins "125") then do:
        if (trim(string(gl.gl)) begins "1259") or substr(string(gl.gl),4,1) = "0" then next gl.
        if lookup(substr(string(gl.gl),1,4),v-aktgl1) <= 0 then do:
            if v-aktgl1 <> "" then v-aktgl1 = v-aktgl1 + "," + substr(string(gl.gl),1,4).
            else v-aktgl1 = substr(string(gl.gl),1,4).
        end.
    end.
    if (trim(string(gl.gl)) begins "130") or (trim(string(gl.gl)) begins "131") or (trim(string(gl.gl)) begins "132") then do:
        if (trim(string(gl.gl)) begins "1319") or (trim(string(gl.gl)) begins "1329") or
        (substr(string(gl.gl),4,1) = "0") then next gl.
        if lookup(substr(string(gl.gl),1,4),v-aktgl2) <= 0 then do:
            if v-aktgl2 <> "" then v-aktgl2 = v-aktgl2 + "," + substr(string(gl.gl),1,4).
            else v-aktgl2 = substr(string(gl.gl),1,4).
        end.
    end.
    if (trim(string(gl.gl)) begins "140") or (trim(string(gl.gl)) begins "141") or (trim(string(gl.gl)) begins "142")
    or (trim(string(gl.gl)) begins "143") then do:
        if (trim(string(gl.gl)) begins "1428") or (trim(string(gl.gl)) begins "1434") or (substr(string(gl.gl),4,1) = "0") then next gl.
        if lookup(substr(string(gl.gl),1,4),v-aktgl3) <= 0 then do:
            if v-aktgl3 <> "" then v-aktgl3 = v-aktgl3 + "," + substr(string(gl.gl),1,4).
            else v-aktgl3 = substr(string(gl.gl),1,4).
        end.
    end.
    if (trim(string(gl.gl)) begins "120") or (trim(string(gl.gl)) begins "145") or (trim(string(gl.gl)) begins "147")
    or (trim(string(gl.gl)) begins "148") then do:
        if (trim(string(gl.gl)) begins "1204") or (substr(string(gl.gl),4,1) = "0") then next gl.
        if lookup(substr(string(gl.gl),1,4),v-aktgl4) <= 0 then do:
            if v-aktgl4 <> "" then v-aktgl4 = v-aktgl4 + "," + substr(string(gl.gl),1,4).
            else v-aktgl4 = substr(string(gl.gl),1,4).
        end.
    end.
    if (trim(string(gl.gl)) begins "146") then do:
        if substr(string(gl.gl),4,1) = "0" then next gl.
        if lookup(substr(string(gl.gl),1,4),v-aktgl5) <= 0 then do:
            if v-aktgl5 <> "" then v-aktgl5 = v-aktgl5 + "," + substr(string(gl.gl),1,4).
            else v-aktgl5 = substr(string(gl.gl),1,4).
        end.
    end.
    if (trim(string(gl.gl)) begins "149") then do:
        if substr(string(gl.gl),4,1) = "0" then next gl.
        if lookup(substr(string(gl.gl),1,4),v-aktgl6) <= 0 then do:
            if v-aktgl6 <> "" then v-aktgl6 = v-aktgl6 + "," + substr(string(gl.gl),1,4).
            else v-aktgl6 = substr(string(gl.gl),1,4).
        end.
    end.

    if (trim(string(gl.gl)) begins "410") or (trim(string(gl.gl)) begins "425") then do:
        if substr(string(gl.gl),4,1) = "0" then next gl.
        if lookup(substr(string(gl.gl),1,4),v-aktglr1) <= 0 then do:
            if v-aktglr1 <> "" then v-aktglr1 = v-aktglr1 + "," + substr(string(gl.gl),1,4).
            else v-aktglr1 = substr(string(gl.gl),1,4).
        end.
    end.
    if (trim(string(gl.gl)) begins "430") or (trim(string(gl.gl)) begins "431") or (trim(string(gl.gl)) begins "432") then do:
        if substr(string(gl.gl),4,1) = "0" then next gl.
        if lookup(substr(string(gl.gl),1,4),v-aktglr2) <= 0 then do:
            if v-aktglr2 <> "" then v-aktglr2 = v-aktglr2 + "," + substr(string(gl.gl),1,4).
            else v-aktglr2 = substr(string(gl.gl),1,4).
        end.
    end.
    if (trim(string(gl.gl)) begins "440") or (trim(string(gl.gl)) begins "441") or (trim(string(gl.gl)) begins "442") or
    (trim(string(gl.gl)) begins "443") then do:
        if substr(string(gl.gl),4,1) = "0" then next gl.
        if lookup(substr(string(gl.gl),1,4),v-aktglr3) <= 0 then do:
            if v-aktglr3 <> "" then v-aktglr3 = v-aktglr3 + "," + substr(string(gl.gl),1,4).
            else v-aktglr3 = substr(string(gl.gl),1,4).
        end.
    end.
    if (trim(string(gl.gl)) begins "420") or (trim(string(gl.gl)) begins "445") or (trim(string(gl.gl)) begins "447") or
    (trim(string(gl.gl)) begins "448") then do:
        if substr(string(gl.gl),4,1) = "0" then next gl.
        if lookup(substr(string(gl.gl),1,4),v-aktglr4) <= 0 then do:
            if v-aktglr4 <> "" then v-aktglr4 = v-aktglr4 + "," + substr(string(gl.gl),1,4).
            else v-aktglr4 = substr(string(gl.gl),1,4).
        end.
    end.
    if (trim(string(gl.gl)) begins "446") then do:
        if substr(string(gl.gl),4,1) = "0" then next gl.
        if lookup(substr(string(gl.gl),1,4),v-aktglr5) <= 0 then do:
            if v-aktglr5 <> "" then v-aktglr5 = v-aktglr5 + "," + substr(string(gl.gl),1,4).
            else v-aktglr5 = substr(string(gl.gl),1,4).
        end.
    end.
    if (trim(string(gl.gl)) begins "449") then do:
        if substr(string(gl.gl),4,1) = "0" then next gl.
        if lookup(substr(string(gl.gl),1,4),v-aktglr6) <= 0 then do:
            if v-aktglr6 <> "" then v-aktglr6 = v-aktglr6 + "," + substr(string(gl.gl),1,4).
            else v-aktglr6 = substr(string(gl.gl),1,4).
        end.
    end.
end.
/*----------------------------АКТИВЫ---------------------------------------------------------------*/
/*displ substr(v-aktgl4,1,105) format "x(105)".
displ substr(v-aktgl4,106,100) format "x(105)".*/

create akt_saldo.
akt_saldo.pr  = yes. akt_saldo.p = 1. akt_saldo.nname  = "Корсчета и вклады в банках, приносящие процентный доход".
/*akt_saldo.ch = "1101,1102,1103,1104,1105,1106,1251,1252,1253,1254,1255,1256".*/
assign akt_saldo.ch = v-aktgl1.
/*akt_saldo.glr = "4052,4103,4251,4253,4254".*/
assign akt_saldo.glr = v-aktglr1.
akt_saldo.fl = "fun".
create akt_saldo.
akt_saldo.pr  = yes. akt_saldo.p = 2. akt_saldo.nname  = "Займы, предоставленные другим банкам". /*akt_saldo.ch = "1302,1303,1304,1305".*/
assign akt_saldo.ch = v-aktgl2.
/*akt_saldo.glr = "4302,4304".*/
assign akt_saldo.glr = v-aktglr2.
akt_saldo.fl = "fun".
create akt_saldo.
akt_saldo.pr  = yes. akt_saldo.p = 3. akt_saldo.nname  = "Займы, предоставленные клиентам (брутто)". /*akt_saldo.ch = "1401,1407,1411,1417,1424".*/
assign akt_saldo.ch = v-aktgl3.
/*akt_saldo.glr = "4401,4407,4411,4417".*/  /*,4429".*/
assign akt_saldo.glr = v-aktglr3.
akt_saldo.fl = "lon".
create akt_saldo.
akt_saldo.pr  = yes. akt_saldo.p = 4. akt_saldo.nname  = "Инвестиции в государственные и прочие ценные бумаги". /*akt_saldo.ch = "1201,1202,1452,1481".*/
assign akt_saldo.ch = v-aktgl4.
/*akt_saldo.glr = "4201,4452,4481,4482,4453,4454,4455".*/
assign akt_saldo.glr = v-aktglr4.
akt_saldo.fl = "scu".
create akt_saldo.
akt_saldo.pr  = yes. akt_saldo.p = 5. akt_saldo.nname  = "Операции обратного Репо". /*akt_saldo.ch = "1461,1462".*/
assign akt_saldo.ch = v-aktgl5.
/*akt_saldo.glr = "4465".*/
assign akt_saldo.glr = v-aktglr5.
akt_saldo.fl = "fun".
create akt_saldo.
akt_saldo.pr  = yes. akt_saldo.p = 6. akt_saldo.nname  = "Прочие процентные активы". /*akt_saldo.ch = "".*/
assign akt_saldo.ch = v-aktgl6.
/*akt_saldo.glr = "".*/
assign akt_saldo.glr = v-aktglr6.
create akt_saldo.
akt_saldo.pr  = no. akt_saldo.p = 7. akt_saldo.nname  = "Итого активы, приносящие процентный доход". akt_saldo.ch = "".
akt_saldo.glr = "".

/*message "Активы" view-as alert-box.
for each akt_saldo no-lock:
    message "G/K = " akt_saldo.ch view-as alert-box.
    message "G/K (po otn. k 1 ur.) = " akt_saldo.glr view-as alert-box.
end.*/

/*----------------------------------------------------------------------------------------*/
def new shared temp-table ob_saldo no-undo
  field pr as logic
  field p as integer
  field fl as char format "x(3)"
  field pp as integer
  field nname as char
  field ch as char
  field glr as char
  index idx is primary p.

def var v-obgl4  as char init "".
def var v-obgl5  as char init "".
def var v-obgl7  as char init "".
def var v-obgl8  as char init "".
def var v-obglr4 as char init "".
def var v-obglr5 as char init "".
def var v-obglr7 as char init "".
def var v-obglr8 as char init "".

/*------------------------Обязательства---------------------------------------------------*/

gl2:
for each gl no-lock use-index gl:
    if (trim(string(gl.gl)) begins "203") or (trim(string(gl.gl)) begins "204") then do:
        if substr(string(gl.gl),4,1) = "0" then next gl2.
        if lookup(substr(string(gl.gl),1,4),v-obgl4) <= 0 then do:
            if v-obgl4 <> "" then v-obgl4 = v-obgl4 + "," + substr(string(gl.gl),1,4).
            else v-obgl4 = substr(string(gl.gl),1,4).
        end.
    end.
    if (trim(string(gl.gl)) begins "202") or (trim(string(gl.gl)) begins "205") or (trim(string(gl.gl)) begins "206") then do:
        if substr(string(gl.gl),4,1) = "0" then next gl2.
        if lookup(substr(string(gl.gl),1,4),v-obgl5) <= 0 then do:
            if v-obgl5 <> "" then v-obgl5 = v-obgl5 + "," + substr(string(gl.gl),1,4).
            else v-obgl5 = substr(string(gl.gl),1,4).
        end.
    end.
    if (trim(string(gl.gl)) begins "240") then do:
        if substr(string(gl.gl),4,1) = "0" then next gl2.
        if lookup(substr(string(gl.gl),1,4),v-obgl7) <= 0 then do:
            if v-obgl7 <> "" then v-obgl7 = v-obgl7 + "," + substr(string(gl.gl),1,4).
            else v-obgl7 = substr(string(gl.gl),1,4).
        end.
    end.
    if (trim(string(gl.gl)) begins "230") or (trim(string(gl.gl)) begins "224") then do:
        if not(trim(string(gl.gl)) begins "224") then do:
            if substr(string(gl.gl),4,1) = "0" then next gl2.
        end.
        if lookup(substr(string(gl.gl),1,4),v-obgl8) <= 0 then do:
            if v-obgl8 <> "" then v-obgl8 = v-obgl8 + "," + substr(string(gl.gl),1,4).
            else v-obgl8 = substr(string(gl.gl),1,4).
        end.
    end.

    if (trim(string(gl.gl)) begins "503") or (trim(string(gl.gl)) begins "504") then do:
        if substr(string(gl.gl),4,1) = "0" then next gl2.
        if lookup(substr(string(gl.gl),1,4),v-obglr4) <= 0 then do:
            if v-obglr4 <> "" then v-obglr4 = v-obglr4 + "," + substr(string(gl.gl),1,4).
            else v-obglr4 = substr(string(gl.gl),1,4).
        end.
    end.
    if (trim(string(gl.gl)) begins "502") or (trim(string(gl.gl)) begins "505") or (trim(string(gl.gl)) begins "509") or
    (trim(string(gl.gl)) begins "506") or (trim(string(gl.gl)) begins "512") then do:
        if substr(string(gl.gl),4,1) = "0" then next gl2.
        if lookup(substr(string(gl.gl),1,4),v-obglr5) <= 0 then do:
            if v-obglr5 <> "" then v-obglr5 = v-obglr5 + "," + substr(string(gl.gl),1,4).
            else v-obglr5 = substr(string(gl.gl),1,4).
        end.
    end.
    if (trim(string(gl.gl)) begins "540") then do:
        if substr(string(gl.gl),4,1) = "0" then next gl2.
        if lookup(substr(string(gl.gl),1,4),v-obglr7) <= 0 then do:
            if v-obglr7 <> "" then v-obglr7 = v-obglr7 + "," + substr(string(gl.gl),1,4).
            else v-obglr7 = substr(string(gl.gl),1,4).
        end.
    end.
    if (trim(string(gl.gl)) begins "530") or (trim(string(gl.gl)) begins "522") then do:
        if substr(string(gl.gl),4,1) = "0" then next gl2.
        if (trim(string(gl.gl)) begins "522") and substr(string(gl.gl),4,1) <> "9" then next gl2.
        if lookup(substr(string(gl.gl),1,4),v-obglr8) <= 0 then do:
            if v-obglr8 <> "" then v-obglr8 = v-obglr8 + "," + substr(string(gl.gl),1,4).
            else v-obglr8 = substr(string(gl.gl),1,4).
        end.
    end.
end.

  create ob_saldo.
  ob_saldo.pr = yes. ob_saldo.p = 1. ob_saldo.nname = "Вклады до востребования". ob_saldo.ch = "2211,2209,2221".
  ob_saldo.glr = "5203,5211".
  ob_saldo.fl = "cif".
  create ob_saldo.
  ob_saldo.pr = yes. ob_saldo.p = 2. ob_saldo.nname = "Срочные вклады клиентов". ob_saldo.ch = "2206,2207,2208,2213,2215,2217,2219,2223".
  ob_saldo.glr = "5215,5217,5223,5219".
  ob_saldo.fl = "cif".
  create ob_saldo.
  ob_saldo.pr = no. ob_saldo.p = 3. ob_saldo.nname = "Всего обязательств перед клиентами". ob_saldo.ch = "".
  ob_saldo.glr = "".
  create ob_saldo.
  ob_saldo.pr = yes. ob_saldo.p = 4.  ob_saldo.nname = "Обязательства перед Правительством и международными финансовыми организациями".
  /*ob_saldo.ch = "2044,2046,2048".*/
  assign ob_saldo.ch = v-obgl4.
  /*ob_saldo.glr = "5034,5036,5037,5038,5044,5046,5047,5048".*/
  assign ob_saldo.glr = v-obglr4.
  ob_saldo.fl = "cif".
  create ob_saldo.
  ob_saldo.pr = yes. ob_saldo.p = 5.  ob_saldo.nname = "Обязательства перед банками". /*ob_saldo.ch = "2013,2123,2124,2125".*/
  assign ob_saldo.ch = v-obgl5.
  /*ob_saldo.glr = "5051,5052,5053,5054,5055,5056,5057,5058,5059,5121,5122,5123,5124,5125,5126,5127,5128,5129,5130,5131,5132,5133".*/
  assign ob_saldo.glr = v-obglr5.
  ob_saldo.fl = "fun".
  create ob_saldo.
  ob_saldo.pr = yes. ob_saldo.p = 6.  ob_saldo.nname = "Операции прямого Репо". ob_saldo.ch = "2255".
  ob_saldo.glr = "5250".
  ob_saldo.fl = "fun".
  create ob_saldo.
  ob_saldo.pr = yes. ob_saldo.p = 7.  ob_saldo.nname = "Субординированный долг". /*ob_saldo.ch = "2401,2402,2405,2406".*/
  assign ob_saldo.ch = v-obgl7.
  /*ob_saldo.glr = "5401,5402,5404,5406,5407".*/
  assign ob_saldo.glr = v-obglr7.
  ob_saldo.fl = "cif".
  create ob_saldo.
  ob_saldo.pr = yes. ob_saldo.p = 8.  ob_saldo.nname = "Прочие процентные обязательства". /*ob_saldo.ch = "".*/
  assign ob_saldo.ch = v-obgl8.
  /*ob_saldo.glr = "".*/
  assign ob_saldo.glr = v-obglr8.
  create ob_saldo.
  ob_saldo.pr = no. ob_saldo.p = 9.  ob_saldo.nname = "Итого обязательства, по которым выплачиваетcя процентное вознаграждение". ob_saldo.ch = "".
  ob_saldo.glr = "".
  create ob_saldo.
  ob_saldo.pr = no. ob_saldo.p = 10.  ob_saldo.nname = "Разница между активами и обязательствами/ Чистый процентный доход/ Спрэд". ob_saldo.ch = "".
  ob_saldo.glr = "".
  create ob_saldo.
  ob_saldo.pr = no. ob_saldo.p = 11.  ob_saldo.nname = "Годовой чистый процентный доход/ Годовая процентная маржа". ob_saldo.ch = "".
  ob_saldo.glr = "".
  create ob_saldo.
  ob_saldo.pr = no. ob_saldo.p = 12.  ob_saldo.nname = "Процентная маржа за период". ob_saldo.ch = "".
  ob_saldo.glr = "".

/*displ substr(v-obgl8,1,105) format "x(105)".
displ substr(v-obgl8,106,100) format "x(105)".*/

/*message "Обязательства" view-as alert-box.
for each ob_saldo no-lock:
    message ob_saldo.nname  ob_saldo.ch view-as alert-box.
end.*/
/*-----------------------------------------------------------------------------------*/

if v-option = "mail" then do:
    assign
    dt = v-update.
    find first bank.cmp no-lock no-error.
    if not avail bank.cmp then do:
        message " Не найдена запись cmp " view-as alert-box error.
        return.
    end.
    def var vv-path as char no-undo.
    /*find first bank.sysc where bank.sysc.sysc = 'bankname' no-lock no-error.
    if avail bank.sysc and bank.cmp.name matches ("*" + bank.sysc.chval + "*")  then vv-path = '/data/b'.
    else vv-path = '/data/'.*/
    if bank.cmp.name matches "*МКО*" then vv-path = '/data/'.
    else vv-path = '/data/b'.
    for each comm.txb where comm.txb.consolid = true no-lock:
        if connected ("txb") then disconnect "txb".
        connect value(" -db " + replace(comm.txb.path,'/data/',vv-path) + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
        run repmarj1.
    end.
    if connected ("txb") then disconnect "txb".
end.
else do:
    /* сбор данных*/
    displ dt  label " Введиту дату " format "99/99/9999" /*validate(dt <= g-today, "Некорректная дата!")*/ skip
    with side-label row 5 centered frame dat.
    update dt with frame dat.
    message "Выберите филиал для формирования данных отчета".
    run txbs ("repmarj1").
    hide message no-pause.
end.

for each akt_saldo no-lock:
    assign  v-sumt = 0 v-sumt1 = 0
            v-sumy = 0 v-sumy1 = 0
            v-rast = 0 v-rast1 = 0 v-rasy = 0.

    create wrk1.
    assign
    wrk1.pr     = akt_saldo.pr
    wrk1.p      = akt_saldo.p
    wrk1.pp     = akt_saldo.p
    wrk1.nname  = akt_saldo.nname.
    for each wrk where wrk.p = akt_saldo.p and wrk.pp = akt_saldo.p no-lock:
        v-sumt  = v-sumt  + wrk.av_saldo.
        v-sumt1 = v-sumt1 + wrk.av_saldo1.
        v-sumy  = v-sumy  + wrk.av_saldo2.
        v-sumy1 = v-sumy1 + wrk.av_saldo3.
    end.
    /*if akt_saldo.p = 3 then message v-sumt + v-sumt1 view-as alert-box.*/
    assign
    wrk1.av_saldo   = round(v-sumt,2)
    wrk1.av_saldo1  = round(v-sumt1,2)
    wrk1.av_saldo2  = round(v-sumy,2)
    wrk1.av_saldo3  = round(v-sumy1,2).

    create wrk1.
    assign
    wrk1.pr     = akt_saldo.pr
    wrk1.p      = akt_saldo.p
    wrk1.pp     = 0
    wrk1.nname  = "данные с начала года".
    assign  v-sumt = 0 v-sumt1 = 0 v-sumy = 0 v-sumy1 = 0.
    for each wrk where wrk.p = akt_saldo.p and wrk.pp = 0 no-lock:
        v-sumt  = v-sumt  + wrk.av_saldo.
        v-sumt1 = v-sumt1 + wrk.av_saldo1.
        v-sumy  = v-sumy  + wrk.av_saldo2.
        v-sumy1 = v-sumy1 + wrk.av_saldo3.
    end.
    assign
    wrk1.av_saldo = round(v-sumt,2)
    wrk1.av_saldo1 = round(v-sumt1,2)
    wrk1.av_saldo2 = round(v-sumy,2)
    wrk1.av_saldo3 = round(v-sumy1,2).
end.

for each ob_saldo no-lock:
    assign  v-sumt = 0 v-sumt1 = 0
            v-sumy = 0 v-sumy1 = 0
            v-rast = 0 v-rast1 = 0 v-rasy = 0 v-rasy1 = 0.
    create wrk3.
    assign
    wrk3.pr     = ob_saldo.pr
    wrk3.p      = ob_saldo.p
    wrk3.pp     = ob_saldo.p
    wrk3.nname  = ob_saldo.nname.
    for each wrk2 where wrk2.p = ob_saldo.p and wrk2.pp = ob_saldo.p no-lock:
        v-sumt  = v-sumt  + wrk2.av_saldo.
        v-sumt1 = v-sumt1 + wrk2.av_saldo1.
        v-sumy  = v-sumy  + wrk2.av_saldo2.
        v-sumy1 = v-sumy1 + wrk2.av_saldo3.
    end.
    assign
    wrk3.av_saldo  = round(v-sumt,2).
    wrk3.av_saldo1 = round(v-sumt1,2).
    wrk3.av_saldo2 = round(v-sumy,2).
    wrk3.av_saldo3 = round(v-sumy1,2).

    create wrk3.
    assign
    wrk3.pr     = ob_saldo.pr
    wrk3.p      = ob_saldo.p
    wrk3.pp     = 0
    wrk3.nname  = "данные с начала года".
    assign  v-sumt = 0 v-sumt1 = 0 v-sumy = 0 v-sumy1 = 0.
    for each wrk2 where wrk2.p = ob_saldo.p and wrk2.pp = 0 no-lock:
        v-sumt  = v-sumt  + wrk2.av_saldo.
        v-sumt1 = v-sumt1 + wrk2.av_saldo1.
        v-sumy  = v-sumy  + wrk2.av_saldo2.
        v-sumy1 = v-sumy1 + wrk2.av_saldo3.
    end.
    assign
    wrk3.av_saldo  = round(v-sumt,2)
    wrk3.av_saldo1 = round(v-sumt1,2)
    wrk3.av_saldo2 = round(v-sumy,2)
    wrk3.av_saldo3 = round(v-sumy1,2).
end.

def var akt-ratet as decim init 0.00.
def var akt-ratey as decim init 0.00.
def var ob-ratet as decim init 0.00.
def var ob-ratey as decim init 0.00.
def var akt-ratet1 as decim init 0.00.
def var akt-ratey1 as decim init 0.00.
def var ob-ratet1 as decim init 0.00.
def var ob-ratey1 as decim init 0.00.
def var akt-ratet3 as decim init 0.00.
def var akt-ratey3 as decim init 0.00.
def var ob-ratet3 as decim init 0.00.
def var ob-ratey3 as decim init 0.00.
def var akt_s as decim.
def var akt_s1 as decim.
def var akt_s3 as decim.
def var ob_r as decim.
def var ob_r1 as decim.
def var ob_r3 as decim.

def var yakt_s as decim.
def var yakt_s1 as decim.
def var yakt_s3 as decim.
def var yob_r as decim.
def var yob_r1 as decim.
def var yob_r3 as decim.


/*--------------------------------------------------------------------------*/

def var v-totsum1 as deci decimals 2.
def var v-totsum2 as deci decimals 2.
def var v-totsum3 as deci decimals 2.
def var v-totsum4 as deci decimals 2.
def var v-totsum5 as deci decimals 2.
def var v-totsum6 as deci decimals 2.
def var v-totsum7 as deci decimals 2.
def var v-totsum8 as deci decimals 2.

/* вывод отчета*/
if v-fil-int > 1 then v-fil-cnt = "консолидированный отчет".
if v-option = "mail" then output stream v-out to value(vfname).
else output stream v-out to repbonus.html.

/* общий (тенге + валюта) отчет  */
    put stream v-out unformatted "<html><head><title></title>"
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    put stream v-out unformatted  "<h5>Анализ процентной маржи  за дату " string(dt) " в сравнении с периодом с начала года (" v-fil-cnt ")  </h5>" skip.
    put stream v-out unformatted  "<tr aling=""left""><td> Таблица 1 </td></tr>" skip.

    put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.

    put stream v-out unformatted "<tr align=center>"
         "<TD><FONT size=""2""><B> &nbsp &nbsp &nbsp </B></FONT></TD>"  skip
         "<TD><FONT size=""2""><B> Наименование </B></FONT></TD>"  skip
         "<TD><FONT size=""2""><B> Ср. месячное<br>сальдо <br>(тыс.тенге) </B></FONT></TD>"  skip
         "<TD><FONT size=""2""><B> Доход/Расход<br>по балансу<br>(тыс.тенге) </B></FONT></TD>" skip
         "<TD><FONT size=""2""><B> Годовая<br>ставка % </B></FONT></TD>" skip
    "</tr>" skip.
    put stream v-out unformatted "<tr align=center>"
         "<TD ></TD>" skip
         "<TD ></TD>" skip
         "<TD align=""left"" ><FONT size=""3""><B> Активы </B></FONT></TD>" skip
    "</tr>" skip.
    assign v-permarj1 = 0 v-permarj2 = 0.
    assign v-godmarj11 = 0 v-godmarj12 = 0 v-godmarj21 = 0 v-godmarj22 = 0.
    assign v-aktobyaz11 = 0 v-aktobyaz12 = 0 v-aktobyaz21 = 0 v-aktobyaz22 = 0 v-aktobyaz31 = 0 v-aktobyaz32 = 0 v-aktobyaz41 = 0
    v-aktobyaz42 = 0 v-aktobyaz51 = 0 v-aktobyaz52 = 0 v-aktobyaz61 = 0 v-aktobyaz62 = 0.
    assign v-totsum1 = 0 v-totsum2 = 0 v-totsum3 = 0 v-totsum4 = 0.
    for each wrk1 no-lock:
        if wrk1.pp <> 0 then do:
            if wrk1.p <> 7 then do:
                v-totsum1 = v-totsum1 + ((wrk1.av_saldo + wrk1.av_saldo1) / 1000).
                v-totsum2 = v-totsum2 + ((wrk1.av_saldo2 + wrk1.av_saldo3) / 1000).
                put stream v-out  unformatted "<TR> <TD align=""left"">" wrk1.p "</TD>" skip
                    "<TD align=""left"">" wrk1.nname "</TD>" skip
                    "<TD align=""right"">" replace(trim(string((wrk1.av_saldo + wrk1.av_saldo1) / 1000,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                    "<TD align=""right"">" replace(trim(string((wrk1.av_saldo2 + wrk1.av_saldo3) / 1000,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip.
                if wrk1.av_saldo + wrk1.av_saldo1 = 0 then do:
                    put stream v-out  unformatted
                    "<TD align=""right"">" replace(trim(string(0,'->>>>>>>>>>>9.99%')),'.',',') "</TD>" skip.
                end.
                else do:
                    put stream v-out  unformatted
                    "<TD align=""right"">" replace(trim(string((((wrk1.av_saldo2 + wrk1.av_saldo3) / 1000) /
                    ((wrk1.av_saldo + wrk1.av_saldo1) / 1000)) * 1200,'->>>>>>>>>>>9.99%')),'.',',') "</TD>" skip.
                end.
            end.
            else do:
                put stream v-out  unformatted "<TR> <TD align=""left""><B>" wrk1.p "</B></TD>" skip
                    "<TD align=""left""><B>" wrk1.nname "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(v-totsum1,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(v-totsum2,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip.
                if v-totsum1 = 0 then do:
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(0,'->>>>>>>>>>>9.99%')),'.',',') "</B></TD>" skip.
                end.
                else do:
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(((v-totsum2) / (v-totsum1)) * 1200,'->>>>>>>>>>>9.99%')),'.',',') "
                    </B></TD>" skip.
                end.
                assign
                v-aktobyaz11 = v-totsum1
                v-aktobyaz21 = v-totsum2
                v-aktobyaz31 = ((v-totsum2) / (v-totsum1)) * 1200.

                assign
                v-godmarj11 = v-totsum1.
            end.
        end.
        else do: /*Данные сначала года*/
            if wrk1.p <> 7 then do:
                v-totsum3 = v-totsum3 + ((wrk1.av_saldo + wrk1.av_saldo1) / 1000).
                v-totsum4 = v-totsum4 + ((wrk1.av_saldo2 + wrk1.av_saldo3) / 1000).
                put stream v-out  unformatted "<TR> <TD align=""left"">"  "</TD>" skip
                    "<TD align=""right"">" wrk1.nname "</TD>" skip
                    "<TD align=""right"">" replace(trim(string((wrk1.av_saldo + wrk1.av_saldo1) / 1000,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                    "<TD align=""right"">" replace(trim(string((wrk1.av_saldo2 + wrk1.av_saldo3) / 1000,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip.
                if wrk1.av_saldo + wrk1.av_saldo1 = 0 then do:
                    put stream v-out  unformatted
                    "<TD align=""right"">" replace(trim(string(0,'->>>>>>>>>>>9.99%')),'.',',') "</TD>" skip.
                end.
                else do:
                    put stream v-out  unformatted
                    "<TD align=""right"">" replace(trim(string((((wrk1.av_saldo2 + wrk1.av_saldo3) / 1000) /
                    ((wrk1.av_saldo + wrk1.av_saldo1) / 1000)) * 1200,'->>>>>>>>>>>9.99%')),'.',',') "</TD>" skip.
                end.
            end.
            else do:
                put stream v-out  unformatted "<TR> <TD align=""left""><B>"  "</B></TD>" skip
                    "<TD align=""right""><B>" wrk1.nname "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(v-totsum3,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(v-totsum4,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip.
                if v-totsum3 = 0 then do:
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(0,'->>>>>>>>>>>9.99%')),'.',',') "</B></TD>" skip.
                end.
                else do:
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(((v-totsum4) / (v-totsum3)) * 1200,'->>>>>>>>>>>9.99%')),'.',',') "
                    </B></TD>" skip.
                end.
                assign
                v-aktobyaz41 = v-totsum3
                v-aktobyaz51 = v-totsum4
                v-aktobyaz61 = ((v-totsum4) / (v-totsum3)) * 1200.

                assign
                v-godmarj21 = v-totsum3.
            end.
        end.
    end.
    put stream v-out unformatted "<tr align=center>"
         "<TD ></TD>" skip
         "<TD ></TD>" skip
         "<TD align=""left"" ><FONT size=""3""><B> Обязательства </B></FONT></TD>" skip
    "</tr>" skip.

    assign v-totsum1 = 0 v-totsum2 = 0 v-totsum3 = 0 v-totsum4 = 0 v-totsum5 = 0 v-totsum6 = 0 v-totsum7 = 0 v-totsum8 = 0.
    for each wrk3 no-lock:
        if wrk3.pp <> 0 then do:
            if wrk3.p = 1 or wrk3.p = 2 then do:
                v-totsum1 = v-totsum1 + ((wrk3.av_saldo + wrk3.av_saldo1) / 1000).
                v-totsum2 = v-totsum2 + ((wrk3.av_saldo2 + wrk3.av_saldo3) / 1000).
                put stream v-out  unformatted "<TR> <TD align=""left"">" wrk3.p "</TD>" skip
                    "<TD align=""left"">" wrk3.nname "</TD>" skip
                    "<TD align=""right"">" replace(trim(string((wrk3.av_saldo + wrk3.av_saldo1) / 1000,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                    "<TD align=""right"">" replace(trim(string((wrk3.av_saldo2 + wrk3.av_saldo3) / 1000,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip.
                if wrk3.av_saldo + wrk3.av_saldo1 = 0 then do:
                    put stream v-out  unformatted
                    "<TD align=""right"">" replace(trim(string(0,'->>>>>>>>>>>9.99%')),'.',',') "</TD>" skip.
                end.
                else do:
                    put stream v-out  unformatted
                    "<TD align=""right"">" replace(trim(string((((wrk3.av_saldo2 + wrk3.av_saldo3) / 1000) /
                    ((wrk3.av_saldo + wrk3.av_saldo1) / 1000)) * 1200,'->>>>>>>>>>>9.99%')),'.',',') "</TD>" skip.
                end.
            end.
            if wrk3.p = 3 then do:
                v-totsum5 = v-totsum5 + v-totsum1.
                v-totsum6 = v-totsum6 + v-totsum2.
                put stream v-out  unformatted "<TR> <TD align=""left""></TD>" skip
                    "<TD align=""left""><B>" wrk3.nname "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(v-totsum1,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(v-totsum2,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip.
                if v-totsum1 = 0 then do:
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(0,'->>>>>>>>>>>9.99%')),'.',',') "</B></TD>" skip.
                end.
                else do:
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(((v-totsum2) / (v-totsum1)) * 1200,'->>>>>>>>>>>9.99%')),'.',',') "
                    </B></TD>" skip.
                end.
            end.
            if wrk3.p = 4 or wrk3.p = 5 or wrk3.p = 6 or wrk3.p = 7 or wrk3.p = 8 then do:
                v-totsum5 = v-totsum5 + ((wrk3.av_saldo + wrk3.av_saldo1) / 1000).
                v-totsum6 = v-totsum6 + ((wrk3.av_saldo2 + wrk3.av_saldo3) / 1000).
                put stream v-out  unformatted "<TR> <TD align=""left"">" wrk3.p - 1 "</TD>" skip
                    "<TD align=""left"">" wrk3.nname "</TD>" skip
                    "<TD align=""right"">" replace(trim(string((wrk3.av_saldo + wrk3.av_saldo1) / 1000,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                    "<TD align=""right"">" replace(trim(string((wrk3.av_saldo2 + wrk3.av_saldo3) / 1000,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip.
                if wrk3.av_saldo + wrk3.av_saldo1 = 0 then do:
                    put stream v-out  unformatted
                    "<TD align=""right"">" replace(trim(string(0,'->>>>>>>>>>>9.99%')),'.',',') "</TD>" skip.
                end.
                else do:
                    put stream v-out  unformatted
                    "<TD align=""right"">" replace(trim(string((((wrk3.av_saldo2 + wrk3.av_saldo3) / 1000) /
                    ((wrk3.av_saldo + wrk3.av_saldo1) / 1000)) * 1200,'->>>>>>>>>>>9.99%')),'.',',') "</TD>" skip.
                end.
            end.
            if wrk3.p = 9 then do:
                put stream v-out  unformatted "<TR> <TD align=""left""><B>" wrk3.p - 1 "</B></TD>" skip
                    "<TD align=""left""><B>" wrk3.nname "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(v-totsum5,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(v-totsum6,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip.
                if v-totsum5 = 0 then do:
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(0,'->>>>>>>>>>>9.99%')),'.',',') "</B></TD>" skip.
                end.
                else do:
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(((v-totsum6) / (v-totsum5)) * 1200,'->>>>>>>>>>>9.99%')),'.',',') "
                    </B></TD>" skip.
                end.
                assign
                v-aktobyaz12 = v-totsum5
                v-aktobyaz22 = v-totsum6
                v-aktobyaz32 = ((v-totsum6) / (v-totsum5)) * 1200.
            end.
            if wrk3.p = 10 then do:
                put stream v-out  unformatted "<TR> <TD align=""left""></TD>" skip
                    "<td></td>" skip
                    "<td></td>" skip
                    "<td></td>" skip
                    "<td></td>" skip
                    "</tr>" skip.
                put stream v-out  unformatted "<TR> <TD align=""left""></TD>" skip
                    "<TD align=""left""><B>" wrk3.nname "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(v-aktobyaz11 - v-aktobyaz12,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(v-aktobyaz21 - v-aktobyaz22,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip.
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(v-aktobyaz31 - v-aktobyaz32,'->>>>>>>>>>>9.99%')),'.',',') "</B></TD>" skip.
                assign
                v-godmarj12 = v-aktobyaz21 - v-aktobyaz22.
            end.
            if wrk3.p = 11 then do:
                put stream v-out  unformatted "<TR> <TD align=""left""></TD>" skip
                    "<TD align=""left""><B>" wrk3.nname "</B></TD>" skip
                    "<TD align=""right""></TD>" skip
                    "<TD align=""right""></TD>" skip.
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(v-godmarj12 / v-godmarj11 * 1200,'->>>>>>>>>>>9.99%')),'.',',') "
                    </B></TD>" skip.
                assign
                v-permarj1 = v-godmarj12 / v-godmarj11 * 1200.
            end.
            if wrk3.p = 12 then do:
                put stream v-out  unformatted "<TR> <TD align=""left""></TD>" skip
                    "<TD align=""left""><B>" wrk3.nname "</B></TD>" skip
                    "<TD align=""right""></TD>" skip
                    "<TD align=""right""></TD>" skip.
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(v-permarj1 / month(dt),'->>>>>>>>>>>9.99%')),'.',',') "</B></TD>" skip.
            end.
        end.
        else do:
            if wrk3.p = 1 or wrk3.p = 2 then do:
                v-totsum3 = v-totsum3 + ((wrk3.av_saldo + wrk3.av_saldo1) / 1000).
                v-totsum4 = v-totsum4 + ((wrk3.av_saldo2 + wrk3.av_saldo3) / 1000).
                put stream v-out  unformatted "<TR> <TD align=""left""></TD>" skip
                    "<TD align=""left"">" wrk3.nname "</TD>" skip
                    "<TD align=""right"">" replace(trim(string((wrk3.av_saldo + wrk3.av_saldo1) / 1000,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                    "<TD align=""right"">" replace(trim(string((wrk3.av_saldo2 + wrk3.av_saldo3) / 1000,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip.
                if wrk3.av_saldo + wrk3.av_saldo1 = 0 then do:
                    put stream v-out  unformatted
                    "<TD align=""right"">" replace(trim(string(0,'->>>>>>>>>>>9.99%')),'.',',') "</TD>" skip.
                end.
                else do:
                    put stream v-out  unformatted
                    "<TD align=""right"">" replace(trim(string((((wrk3.av_saldo2 + wrk3.av_saldo3) / 1000) /
                    ((wrk3.av_saldo + wrk3.av_saldo1) / 1000)) * 1200,'->>>>>>>>>>>9.99%')),'.',',') "</TD>" skip.
                end.
            end.
            if wrk3.p = 3 then do:
                v-totsum7 = v-totsum7 + v-totsum3.
                v-totsum8 = v-totsum8 + v-totsum4.
                put stream v-out  unformatted "<TR> <TD align=""left""></TD>" skip
                    "<TD align=""left""><B>" wrk3.nname "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(v-totsum3,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(v-totsum4,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip.
                if v-totsum3 = 0 then do:
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(0,'->>>>>>>>>>>9.99%')),'.',',') "</B></TD>" skip.
                end.
                else do:
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(((v-totsum4) / (v-totsum3)) * 1200,'->>>>>>>>>>>9.99%')),'.',',') "
                    </B></TD>" skip.
                end.
            end.
            if wrk3.p = 4 or wrk3.p = 5 or wrk3.p = 6 or wrk3.p = 7 or wrk3.p = 8 then do:
                v-totsum7 = v-totsum7 + ((wrk3.av_saldo + wrk3.av_saldo1) / 1000).
                v-totsum8 = v-totsum8 + ((wrk3.av_saldo2 + wrk3.av_saldo3) / 1000).
                put stream v-out  unformatted "<TR> <TD align=""left""></TD>" skip
                    "<TD align=""left"">" wrk3.nname "</TD>" skip
                    "<TD align=""right"">" replace(trim(string((wrk3.av_saldo + wrk3.av_saldo1) / 1000,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                    "<TD align=""right"">" replace(trim(string((wrk3.av_saldo2 + wrk3.av_saldo3) / 1000,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip.
                if wrk3.av_saldo + wrk3.av_saldo1 = 0 then do:
                    put stream v-out  unformatted
                    "<TD align=""right"">" replace(trim(string(0,'->>>>>>>>>>>9.99%')),'.',',') "</TD>" skip.
                end.
                else do:
                    put stream v-out  unformatted
                    "<TD align=""right"">" replace(trim(string((((wrk3.av_saldo2 + wrk3.av_saldo3) / 1000) /
                    ((wrk3.av_saldo + wrk3.av_saldo1) / 1000)) * 1200,'->>>>>>>>>>>9.99%')),'.',',') "</TD>" skip.
                end.
            end.
            if wrk3.p = 9 then do:
                put stream v-out  unformatted "<TR> <TD align=""left""></TD>" skip
                    "<TD align=""left""><B>" wrk3.nname "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(v-totsum7,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(v-totsum8,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip.
                if v-totsum7 = 0 then do:
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(0,'->>>>>>>>>>>9.99%')),'.',',') "</B></TD>" skip.
                end.
                else do:
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(((v-totsum8) / (v-totsum7)) * 1200,'->>>>>>>>>>>9.99%')),'.',',') "
                    </B></TD>" skip.
                end.
                assign
                v-aktobyaz42 = v-totsum7
                v-aktobyaz52 = v-totsum8
                v-aktobyaz62 = ((v-totsum8) / (v-totsum7)) * 1200.
            end.
            if wrk3.p = 10 then do:
                put stream v-out  unformatted "<TR> <TD align=""left""></TD>" skip
                    "<TD align=""left""><B>" wrk3.nname "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(v-aktobyaz41 - v-aktobyaz42,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(v-aktobyaz51 - v-aktobyaz52,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip.
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(v-aktobyaz61 - v-aktobyaz62,'->>>>>>>>>>>9.99%')),'.',',') "</B></TD>" skip.
                assign
                v-godmarj22 = v-aktobyaz51 - v-aktobyaz52.
            end.
            if wrk3.p = 11 then do:
                put stream v-out  unformatted "<TR> <TD align=""left""></TD>" skip
                    "<TD align=""left""><B>" wrk3.nname "</B></TD>" skip
                    "<TD align=""right""></TD>" skip
                    "<TD align=""right""></TD>" skip.
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(v-godmarj22 / v-godmarj21 * 1200,'->>>>>>>>>>>9.99%')),'.',',') "
                    </B></TD>" skip.
                assign
                v-permarj2 = v-godmarj22 / v-godmarj21 * 1200.
            end.
            if wrk3.p = 12 then do:
                put stream v-out  unformatted "<TR> <TD align=""left""></TD>" skip
                    "<TD align=""left""><B>" wrk3.nname "</B></TD>" skip
                    "<TD align=""right""></TD>" skip
                    "<TD align=""right""></TD>" skip.
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(v-permarj2 / month(dt),'->>>>>>>>>>>9.99%')),'.',',') "</B></TD>" skip.
            end.
        end.
    end.

    put stream v-out unformatted "</table>".

/*тенговый отчет  */
    put stream v-out unformatted "<html><head><title></title>"
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    put stream v-out unformatted  "<h5>Анализ процентной маржи в тенге за дату " string(dt) " в сравнении с периодом с начала года (" v-fil-cnt ") </h5>" skip.
    put stream v-out unformatted  "<tr aling=""left""><td> Таблица 2 </td></tr>" skip.

    put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.

    put stream v-out unformatted "<tr align=center>"
         "<TD><FONT size=""2""><B> &nbsp &nbsp &nbsp </B></FONT></TD>"  skip
         "<TD><FONT size=""2""><B> Наименование </B></FONT></TD>"  skip
         "<TD><FONT size=""2""><B> Ср. месячное<br>сальдо <br>(тыс.тенге) </B></FONT></TD>"  skip
         "<TD><FONT size=""2""><B> Доход/Расход<br>по балансу<br>(тыс.тенге) </B></FONT></TD>" skip
         "<TD><FONT size=""2""><B> Годовая<br>ставка % </B></FONT></TD>" skip
    "</tr>" skip.
    put stream v-out unformatted "<tr align=center>"
         "<TD ></TD>" skip
         "<TD ></TD>" skip
         "<TD align=""left"" ><FONT size=""3""><B> Активы </B></FONT></TD>" skip
    "</tr>" skip.
    assign v-permarj1 = 0 v-permarj2 = 0.
    assign v-godmarj11 = 0 v-godmarj12 = 0 v-godmarj21 = 0 v-godmarj22 = 0.
    assign v-aktobyaz11 = 0 v-aktobyaz12 = 0 v-aktobyaz21 = 0 v-aktobyaz22 = 0 v-aktobyaz31 = 0 v-aktobyaz32 = 0 v-aktobyaz41 = 0
    v-aktobyaz42 = 0 v-aktobyaz51 = 0 v-aktobyaz52 = 0 v-aktobyaz61 = 0 v-aktobyaz62 = 0.
    assign v-totsum1 = 0 v-totsum2 = 0 v-totsum3 = 0 v-totsum4 = 0.
    for each wrk1 no-lock.
        if wrk1.pp <> 0 then do:
            if wrk1.p <> 7 then do:
                v-totsum1 = v-totsum1 + (wrk1.av_saldo / 1000).
                v-totsum2 = v-totsum2 + (wrk1.av_saldo2 / 1000).
                put stream v-out  unformatted "<TR> <TD align=""left"">" wrk1.p "</TD>" skip
                    "<TD align=""left"">" wrk1.nname "</TD>" skip
                    "<TD align=""right"">" replace(trim(string(wrk1.av_saldo / 1000,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                    "<TD align=""right"">" replace(trim(string(wrk1.av_saldo2 / 1000,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip.
                if wrk1.av_saldo = 0 then do:
                    put stream v-out  unformatted
                    "<TD align=""right"">" replace(trim(string(0,'->>>>>>>>>>>9.99%')),'.',',') "</TD>" skip.
                end.
                else do:
                    put stream v-out  unformatted
                    "<TD align=""right"">" replace(trim(string((((wrk1.av_saldo2) / 1000) /
                    ((wrk1.av_saldo) / 1000)) * 1200,'->>>>>>>>>>>9.99%')),'.',',') "</TD>" skip.
                end.
            end.
            else do:
                put stream v-out  unformatted "<TR> <TD align=""left""><B>" wrk1.p "</B></TD>" skip
                    "<TD align=""left""><B>" wrk1.nname "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(v-totsum1,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(v-totsum2,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip.
                if v-totsum1 = 0 then do:
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(0,'->>>>>>>>>>>9.99%')),'.',',') "</B></TD>" skip.
                end.
                else do:
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(((v-totsum2) / (v-totsum1)) * 1200,'->>>>>>>>>>>9.99%')),'.',',') "
                    </B></TD>" skip.
                end.
                assign
                v-aktobyaz11 = v-totsum1
                v-aktobyaz21 = v-totsum2
                v-aktobyaz31 = ((v-totsum2) / (v-totsum1)) * 1200.

                assign
                v-godmarj11 = v-totsum1.
            end.
        end.
        else do:
            if wrk1.p <> 7 then do:
                v-totsum3 = v-totsum3 + (wrk1.av_saldo / 1000).
                v-totsum4 = v-totsum4 + (wrk1.av_saldo2 / 1000).
                put stream v-out  unformatted "<TR> <TD align=""left"">"  "</TD>" skip
                 "<TD align=""right"">" wrk1.nname "</TD>" skip
                    "<TD align=""right"">" replace(trim(string(wrk1.av_saldo / 1000,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                    "<TD align=""right"">" replace(trim(string(wrk1.av_saldo2 / 1000,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip.
                if wrk1.av_saldo = 0 then do:
                    put stream v-out  unformatted
                    "<TD align=""right"">" replace(trim(string(0,'->>>>>>>>>>>9.99%')),'.',',') "</TD>" skip.
                end.
                else do:
                    put stream v-out  unformatted
                    "<TD align=""right"">" replace(trim(string((((wrk1.av_saldo2) / 1000) /
                    ((wrk1.av_saldo) / 1000)) * 1200,'->>>>>>>>>>>9.99%')),'.',',') "</TD>" skip.
                end.
            end.
            else do:
                put stream v-out  unformatted "<TR> <TD align=""left"">"  "</TD>" skip
                 "<TD align=""right""><B>" wrk1.nname "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(v-totsum3,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(v-totsum4,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip.
                if v-totsum3 = 0 then do:
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(0,'->>>>>>>>>>>9.99%')),'.',',') "</B></TD>" skip.
                end.
                else do:
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(((v-totsum4) / (v-totsum3)) * 1200,'->>>>>>>>>>>9.99%')),'.',',') "
                    </B></TD>" skip.
                end.
                assign
                v-aktobyaz41 = v-totsum3
                v-aktobyaz51 = v-totsum4
                v-aktobyaz61 = ((v-totsum4) / (v-totsum3)) * 1200.

                assign
                v-godmarj21 = v-totsum3.
            end.
        end.
    end.
    put stream v-out unformatted "<tr align=center>"
         "<TD ></TD>" skip
         "<TD ></TD>" skip
         "<TD align=""left"" ><FONT size=""3""><B> Обязательства </B></FONT></TD>" skip
    "</tr>" skip.

    assign v-totsum1 = 0 v-totsum2 = 0 v-totsum3 = 0 v-totsum4 = 0 v-totsum5 = 0 v-totsum6 = 0 v-totsum7 = 0 v-totsum8 = 0.
    for each wrk3 no-lock:
        if wrk3.pp <> 0 then do:
            if wrk3.p = 1 or wrk3.p = 2 then do:
                v-totsum1 = v-totsum1 + ((wrk3.av_saldo) / 1000).
                v-totsum2 = v-totsum2 + ((wrk3.av_saldo2) / 1000).
                put stream v-out  unformatted "<TR> <TD align=""left"">" wrk3.p "</TD>" skip
                    "<TD align=""left"">" wrk3.nname "</TD>" skip
                    "<TD align=""right"">" replace(trim(string((wrk3.av_saldo) / 1000,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                    "<TD align=""right"">" replace(trim(string((wrk3.av_saldo2) / 1000,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip.
                if wrk3.av_saldo = 0 then do:
                    put stream v-out  unformatted
                    "<TD align=""right"">" replace(trim(string(0,'->>>>>>>>>>>9.99%')),'.',',') "</TD>" skip.
                end.
                else do:
                    put stream v-out  unformatted
                    "<TD align=""right"">" replace(trim(string((((wrk3.av_saldo2) / 1000) /
                    ((wrk3.av_saldo) / 1000)) * 1200,'->>>>>>>>>>>9.99%')),'.',',') "</TD>" skip.
                end.
            end.
            if wrk3.p = 3 then do:
                v-totsum5 = v-totsum5 + v-totsum1.
                v-totsum6 = v-totsum6 + v-totsum2.
                put stream v-out  unformatted "<TR> <TD align=""left""></TD>" skip
                    "<TD align=""left""><B>" wrk3.nname "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(v-totsum1,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(v-totsum2,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip.
                if v-totsum1 = 0 then do:
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(0,'->>>>>>>>>>>9.99%')),'.',',') "</B></TD>" skip.
                end.
                else do:
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(((v-totsum2) / (v-totsum1)) * 1200,'->>>>>>>>>>>9.99%')),'.',',') "
                    </B></TD>" skip.
                end.
            end.
            if wrk3.p = 4 or wrk3.p = 5 or wrk3.p = 6 or wrk3.p = 7 or wrk3.p = 8 then do:
                v-totsum5 = v-totsum5 + ((wrk3.av_saldo) / 1000).
                v-totsum6 = v-totsum6 + ((wrk3.av_saldo2) / 1000).
                put stream v-out  unformatted "<TR> <TD align=""left"">" wrk3.p - 1 "</TD>" skip
                    "<TD align=""left"">" wrk3.nname "</TD>" skip
                    "<TD align=""right"">" replace(trim(string((wrk3.av_saldo) / 1000,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                    "<TD align=""right"">" replace(trim(string((wrk3.av_saldo2) / 1000,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip.
                if wrk3.av_saldo = 0 then do:
                    put stream v-out  unformatted
                    "<TD align=""right"">" replace(trim(string(0,'->>>>>>>>>>>9.99%')),'.',',') "</TD>" skip.
                end.
                else do:
                    put stream v-out  unformatted
                    "<TD align=""right"">" replace(trim(string((((wrk3.av_saldo2) / 1000) /
                    ((wrk3.av_saldo) / 1000)) * 1200,'->>>>>>>>>>>9.99%')),'.',',') "</TD>" skip.
                end.
            end.
            if wrk3.p = 9 then do:
                put stream v-out  unformatted "<TR> <TD align=""left""><B>" wrk3.p - 1 "</TD>" skip
                    "<TD align=""left""><B>" wrk3.nname "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(v-totsum5,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(v-totsum6,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip.
                if v-totsum5 = 0 then do:
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(0,'->>>>>>>>>>>9.99%')),'.',',') "</B></TD>" skip.
                end.
                else do:
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(((v-totsum6) / (v-totsum5)) * 1200,'->>>>>>>>>>>9.99%')),'.',',') "
                    </B></TD>" skip.
                end.
                assign
                v-aktobyaz12 = v-totsum5
                v-aktobyaz22 = v-totsum6
                v-aktobyaz32 = ((v-totsum6) / (v-totsum5)) * 1200.
            end.
            if wrk3.p = 10 then do:
                put stream v-out  unformatted "<TR> <TD align=""left""></TD>" skip
                    "<TD align=""left""><B>" wrk3.nname "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(v-aktobyaz11 - v-aktobyaz12,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(v-aktobyaz21 - v-aktobyaz22,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip.
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(v-aktobyaz31 - v-aktobyaz32,'->>>>>>>>>>>9.99%')),'.',',') "</B></TD>" skip.
                assign
                v-godmarj12 = v-aktobyaz21 - v-aktobyaz22.
            end.
            if wrk3.p = 11 then do:
                put stream v-out  unformatted "<TR> <TD align=""left""></TD>" skip
                    "<TD align=""left""><B>" wrk3.nname "</B></TD>" skip
                    "<TD align=""right""></TD>" skip
                    "<TD align=""right""></TD>" skip.
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(v-godmarj12 / v-godmarj11 * 1200,'->>>>>>>>>>>9.99%')),'.',',') "
                    </B></TD>" skip.
                assign
                v-permarj1 = v-godmarj12 / v-godmarj11 * 1200.
            end.
            if wrk3.p = 12 then do:
                put stream v-out  unformatted "<TR> <TD align=""left""></TD>" skip
                    "<TD align=""left""><B>" wrk3.nname "</B></TD>" skip
                    "<TD align=""right""></TD>" skip
                    "<TD align=""right""></TD>" skip.
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(v-permarj1 / month(dt),'->>>>>>>>>>>9.99%')),'.',',') "</B></TD>" skip.
            end.
        end.
        else do:
            if wrk3.p = 1 or wrk3.p = 2 then do:
                v-totsum3 = v-totsum3 + ((wrk3.av_saldo) / 1000).
                v-totsum4 = v-totsum4 + ((wrk3.av_saldo2) / 1000).
                put stream v-out  unformatted "<TR> <TD align=""left""></TD>" skip
                    "<TD align=""left"">" wrk3.nname "</TD>" skip
                    "<TD align=""right"">" replace(trim(string((wrk3.av_saldo) / 1000,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                    "<TD align=""right"">" replace(trim(string((wrk3.av_saldo2) / 1000,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip.
                if wrk3.av_saldo = 0 then do:
                    put stream v-out  unformatted
                    "<TD align=""right"">" replace(trim(string(0,'->>>>>>>>>>>9.99%')),'.',',') "</TD>" skip.
                end.
                else do:
                    put stream v-out  unformatted
                    "<TD align=""right"">" replace(trim(string((((wrk3.av_saldo2) / 1000) /
                    ((wrk3.av_saldo) / 1000)) * 1200,'->>>>>>>>>>>9.99%')),'.',',') "</TD>" skip.
                end.
            end.
            if wrk3.p = 3 then do:
                v-totsum7 = v-totsum7 + v-totsum3.
                v-totsum8 = v-totsum8 + v-totsum4.
                put stream v-out  unformatted "<TR> <TD align=""left""></TD>" skip
                    "<TD align=""left""><B>" wrk3.nname "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(v-totsum3,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(v-totsum4,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip.
                if v-totsum3 = 0 then do:
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(0,'->>>>>>>>>>>9.99%')),'.',',') "</B></TD>" skip.
                end.
                else do:
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(((v-totsum4) / (v-totsum3)) * 1200,'->>>>>>>>>>>9.99%')),'.',',') "
                    </B></TD>" skip.
                end.
            end.
            if wrk3.p = 4 or wrk3.p = 5 or wrk3.p = 6 or wrk3.p = 7 or wrk3.p = 8 then do:
                v-totsum7 = v-totsum7 + ((wrk3.av_saldo) / 1000).
                v-totsum8 = v-totsum8 + ((wrk3.av_saldo2) / 1000).
                put stream v-out  unformatted "<TR> <TD align=""left""></TD>" skip
                    "<TD align=""left"">" wrk3.nname "</TD>" skip
                    "<TD align=""right"">" replace(trim(string((wrk3.av_saldo) / 1000,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                    "<TD align=""right"">" replace(trim(string((wrk3.av_saldo2) / 1000,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip.
                if wrk3.av_saldo = 0 then do:
                    put stream v-out  unformatted
                    "<TD align=""right"">" replace(trim(string(0,'->>>>>>>>>>>9.99%')),'.',',') "</TD>" skip.
                end.
                else do:
                    put stream v-out  unformatted
                    "<TD align=""right"">" replace(trim(string((((wrk3.av_saldo2) / 1000) /
                    ((wrk3.av_saldo) / 1000)) * 1200,'->>>>>>>>>>>9.99%')),'.',',') "</TD>" skip.
                end.
            end.
            if wrk3.p = 9 then do:
                put stream v-out  unformatted "<TR> <TD align=""left""></TD>" skip
                    "<TD align=""left""><B>" wrk3.nname "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(v-totsum7,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(v-totsum8,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip.
                if v-totsum7 = 0 then do:
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(0,'->>>>>>>>>>>9.99%')),'.',',') "</B></TD>" skip.
                end.
                else do:
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(((v-totsum8) / (v-totsum7)) * 1200,'->>>>>>>>>>>9.99%')),'.',',') "
                    </B></TD>" skip.
                end.
                assign
                v-aktobyaz42 = v-totsum7
                v-aktobyaz52 = v-totsum8
                v-aktobyaz62 = ((v-totsum8) / (v-totsum7)) * 1200.
            end.
            if wrk3.p = 10 then do:
                put stream v-out  unformatted "<TR> <TD align=""left""></TD>" skip
                    "<TD align=""left""><B>" wrk3.nname "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(v-aktobyaz41 - v-aktobyaz42,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(v-aktobyaz51 - v-aktobyaz52,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip.
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(v-aktobyaz61 - v-aktobyaz62,'->>>>>>>>>>>9.99%')),'.',',') "</B></TD>" skip.
                assign
                v-godmarj22 = v-aktobyaz51 - v-aktobyaz52.
            end.
            if wrk3.p = 11 then do:
                put stream v-out  unformatted "<TR> <TD align=""left""></TD>" skip
                    "<TD align=""left""><B>" wrk3.nname "</B></TD>" skip
                    "<TD align=""right""></TD>" skip
                    "<TD align=""right""></TD>" skip.
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(v-godmarj22 / v-godmarj21 * 1200,'->>>>>>>>>>>9.99%')),'.',',') "
                    </B></TD>" skip.
                assign
                v-permarj2 = v-godmarj22 / v-godmarj21 * 1200.
            end.
            if wrk3.p = 12 then do:
                put stream v-out  unformatted "<TR> <TD align=""left""></TD>" skip
                    "<TD align=""left""><B>" wrk3.nname "</B></TD>" skip
                    "<TD align=""right""></TD>" skip
                    "<TD align=""right""></TD>" skip.
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(v-permarj2 / month(dt),'->>>>>>>>>>>9.99%')),'.',',') "</B></TD>" skip.
            end.
        end.
    end.

    put stream v-out unformatted "</table>".

/* валютный отчет  */
    put stream v-out unformatted "<html><head><title></title>"
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    put stream v-out unformatted  "<h5>Анализ процентной маржи в валюте за дату " string(dt) " в сравнении с периодом с начала года (" v-fil-cnt ") </h5>" skip.
    put stream v-out unformatted  "<tr aling=""left""><td> Таблица 3 </td></tr>" skip.

    put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.

    put stream v-out unformatted "<tr align=center>"
         "<TD><FONT size=""2""><B> &nbsp &nbsp &nbsp </B></FONT></TD>"  skip
         "<TD><FONT size=""2""><B> Наименование </B></FONT></TD>"  skip
         "<TD><FONT size=""2""><B> Ср. месячное<br>сальдо <br>(тыс.тенге) </B></FONT></TD>"  skip
         "<TD><FONT size=""2""><B> Доход/Расход<br>по балансу<br>(тыс.тенге) </B></FONT></TD>" skip
         "<TD><FONT size=""2""><B> Годовая<br>ставка % </B></FONT></TD>" skip
    "</tr>" skip.
    put stream v-out unformatted "<tr align=center>"
         "<TD ></TD>" skip
         "<TD ></TD>" skip
         "<TD align=""left"" ><FONT size=""3""><B> Активы </B></FONT></TD>" skip
    "</tr>" skip.
    assign v-permarj1 = 0 v-permarj2 = 0.
    assign v-godmarj11 = 0 v-godmarj12 = 0 v-godmarj21 = 0 v-godmarj22 = 0.
    assign v-aktobyaz11 = 0 v-aktobyaz12 = 0 v-aktobyaz21 = 0 v-aktobyaz22 = 0 v-aktobyaz31 = 0 v-aktobyaz32 = 0 v-aktobyaz41 = 0
    v-aktobyaz42 = 0 v-aktobyaz51 = 0 v-aktobyaz52 = 0 v-aktobyaz61 = 0 v-aktobyaz62 = 0.
    assign v-totsum1 = 0 v-totsum2 = 0 v-totsum3 = 0 v-totsum4 = 0.
    for each wrk1 no-lock.
        if wrk1.pp <> 0 then do:
            if wrk1.p <> 7 then do:
                v-totsum1 = v-totsum1 + (wrk1.av_saldo1 / 1000).
                v-totsum2 = v-totsum2 + (wrk1.av_saldo3 / 1000).
                put stream v-out  unformatted "<TR> <TD align=""left"">" wrk1.p "</TD>" skip
                    "<TD align=""left"">" wrk1.nname "</TD>" skip
                    "<TD align=""right"">" replace(trim(string(wrk1.av_saldo1 / 1000,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                    "<TD align=""right"">" replace(trim(string(wrk1.av_saldo3 / 1000,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip.
                if wrk1.av_saldo1 = 0 then do:
                    put stream v-out  unformatted
                    "<TD align=""right"">" replace(trim(string(0,'->>>>>>>>>>>9.99%')),'.',',') "</TD>" skip.
                end.
                else do:
                    put stream v-out  unformatted
                    "<TD align=""right"">" replace(trim(string((((wrk1.av_saldo3) / 1000) /
                    ((wrk1.av_saldo1) / 1000)) * 1200,'->>>>>>>>>>>9.99%')),'.',',') "</TD>" skip.
                end.
            end.
            else do:
                put stream v-out  unformatted "<TR> <TD align=""left""><B>" wrk1.p "</B></TD>" skip
                    "<TD align=""left""><B>" wrk1.nname "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(v-totsum1,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(v-totsum2,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip.
                if v-totsum1 = 0 then do:
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(0,'->>>>>>>>>>>9.99%')),'.',',') "</B></TD>" skip.
                end.
                else do:
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(((v-totsum2) / (v-totsum1)) * 1200,'->>>>>>>>>>>9.99%')),'.',',') "
                    </B></TD>" skip.
                end.
                assign
                v-aktobyaz11 = v-totsum1
                v-aktobyaz21 = v-totsum2
                v-aktobyaz31 = ((v-totsum2) / (v-totsum1)) * 1200.
                assign
                v-godmarj11 = v-totsum1.
            end.
        end.
        else do:
            if wrk1.p <> 7 then do:
                v-totsum3 = v-totsum3 + (wrk1.av_saldo1 / 1000).
                v-totsum4 = v-totsum4 + (wrk1.av_saldo3 / 1000).
                put stream v-out  unformatted "<TR> <TD align=""left"">"  "</TD>" skip
                "<TD align=""right"">" wrk1.nname "</B></TD>" skip
                    "<TD align=""right"">" replace(trim(string((wrk1.av_saldo1) / 1000,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                    "<TD align=""right"">" replace(trim(string((wrk1.av_saldo3) / 1000,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip.
                if wrk1.av_saldo1 = 0 then do:
                    put stream v-out  unformatted
                    "<TD align=""right"">" replace(trim(string(0,'->>>>>>>>>>>9.99%')),'.',',') "</TD>" skip.
                end.
                else do:
                    put stream v-out  unformatted
                    "<TD align=""right"">" replace(trim(string((((wrk1.av_saldo3) / 1000) /
                    ((wrk1.av_saldo1) / 1000)) * 1200,'->>>>>>>>>>>9.99%')),'.',',') "</TD>" skip.
                end.
            end.
            else do:
                put stream v-out  unformatted "<TR> <TD align=""left"">"  "</TD>" skip
                "<TD align=""right""><B>" wrk1.nname "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(v-totsum3,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(v-totsum4,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip.
                if v-totsum3 = 0 then do:
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(0,'->>>>>>>>>>>9.99%')),'.',',') "</B></TD>" skip.
                end.
                else do:
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(((v-totsum4) / (v-totsum3)) * 1200,'->>>>>>>>>>>9.99%')),'.',',') "
                    </B></TD>" skip.
                end.
                assign
                v-aktobyaz41 = v-totsum3
                v-aktobyaz51 = v-totsum4
                v-aktobyaz61 = ((v-totsum4) / (v-totsum3)) * 1200.
                assign
                v-godmarj21 = v-totsum3.
            end.
        end.
    end.
    put stream v-out unformatted "<tr align=center>"
         "<TD ></TD>" skip
         "<TD ></TD>" skip
         "<TD align=""left"" ><FONT size=""3""><B> Обязательства </B></FONT></TD>" skip
    "</tr>" skip.

    assign v-totsum1 = 0 v-totsum2 = 0 v-totsum3 = 0 v-totsum4 = 0 v-totsum5 = 0 v-totsum6 = 0 v-totsum7 = 0 v-totsum8 = 0.
    for each wrk3 no-lock:
        if wrk3.pp <> 0 then do:
            if wrk3.p = 1 or wrk3.p = 2 then do:
                v-totsum1 = v-totsum1 + ((wrk3.av_saldo1) / 1000).
                v-totsum2 = v-totsum2 + ((wrk3.av_saldo3) / 1000).
                put stream v-out  unformatted "<TR> <TD align=""left"">" wrk3.p "</TD>" skip
                    "<TD align=""left"">" wrk3.nname "</TD>" skip
                    "<TD align=""right"">" replace(trim(string((wrk3.av_saldo1) / 1000,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                    "<TD align=""right"">" replace(trim(string((wrk3.av_saldo3) / 1000,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip.
                if wrk3.av_saldo1 = 0 then do:
                    put stream v-out  unformatted
                    "<TD align=""right"">" replace(trim(string(0,'->>>>>>>>>>>9.99%')),'.',',') "</TD>" skip.
                end.
                else do:
                    put stream v-out  unformatted
                    "<TD align=""right"">" replace(trim(string((((wrk3.av_saldo3) / 1000) /
                    ((wrk3.av_saldo1) / 1000)) * 1200,'->>>>>>>>>>>9.99%')),'.',',') "</TD>" skip.
                end.
            end.
            if wrk3.p = 3 then do:
                v-totsum5 = v-totsum5 + v-totsum1.
                v-totsum6 = v-totsum6 + v-totsum2.
                put stream v-out  unformatted "<TR> <TD align=""left""></TD>" skip
                    "<TD align=""left""><B>" wrk3.nname "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(v-totsum1,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(v-totsum2,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip.
                if v-totsum1 = 0 then do:
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(0,'->>>>>>>>>>>9.99%')),'.',',') "</B></TD>" skip.
                end.
                else do:
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(((v-totsum2) / (v-totsum1)) * 1200,'->>>>>>>>>>>9.99%')),'.',',') "
                    </B></TD>" skip.
                end.
            end.
            if wrk3.p = 4 or wrk3.p = 5 or wrk3.p = 6 or wrk3.p = 7 or wrk3.p = 8 then do:
                v-totsum5 = v-totsum5 + ((wrk3.av_saldo1) / 1000).
                v-totsum6 = v-totsum6 + ((wrk3.av_saldo3) / 1000).
                put stream v-out  unformatted "<TR> <TD align=""left"">" wrk3.p - 1 "</TD>" skip
                    "<TD align=""left"">" wrk3.nname "</TD>" skip
                    "<TD align=""right"">" replace(trim(string((wrk3.av_saldo1) / 1000,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                    "<TD align=""right"">" replace(trim(string((wrk3.av_saldo3) / 1000,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip.
                if wrk3.av_saldo1 = 0 then do:
                    put stream v-out  unformatted
                    "<TD align=""right"">" replace(trim(string(0,'->>>>>>>>>>>9.99%')),'.',',') "</TD>" skip.
                end.
                else do:
                    put stream v-out  unformatted
                    "<TD align=""right"">" replace(trim(string((((wrk3.av_saldo3) / 1000) /
                    ((wrk3.av_saldo1) / 1000)) * 1200,'->>>>>>>>>>>9.99%')),'.',',') "</TD>" skip.
                end.
            end.
            if wrk3.p = 9 then do:
                put stream v-out  unformatted "<TR> <TD align=""left""><B>" wrk3.p - 1 "</B></TD>" skip
                    "<TD align=""left""><B>" wrk3.nname "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(v-totsum5,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(v-totsum6,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip.
                if v-totsum5 = 0 then do:
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(0,'->>>>>>>>>>>9.99%')),'.',',') "</B></TD>" skip.
                end.
                else do:
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(((v-totsum6) / (v-totsum5)) * 1200,'->>>>>>>>>>>9.99%')),'.',',') "
                    </B></TD>" skip.
                end.
                assign
                v-aktobyaz12 = v-totsum5
                v-aktobyaz22 = v-totsum6
                v-aktobyaz32 = ((v-totsum6) / (v-totsum5)) * 1200.
            end.
            if wrk3.p = 10 then do:
                put stream v-out  unformatted "<TR> <TD align=""left""></TD>" skip
                    "<TD align=""left""><B>" wrk3.nname "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(v-aktobyaz11 - v-aktobyaz12,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(v-aktobyaz21 - v-aktobyaz22,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip.
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(v-aktobyaz31 - v-aktobyaz32,'->>>>>>>>>>>9.99%')),'.',',') "</B></TD>" skip.
                assign
                v-godmarj12 = v-aktobyaz21 - v-aktobyaz22.
            end.
            if wrk3.p = 11 then do:
                put stream v-out  unformatted "<TR> <TD align=""left""></TD>" skip
                    "<TD align=""left""><B>" wrk3.nname "</B></TD>" skip
                    "<TD align=""right""></TD>" skip
                    "<TD align=""right""></TD>" skip.
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(v-godmarj12 / v-godmarj11 * 1200,'->>>>>>>>>>>9.99%')),'.',',') "
                    </B></TD>" skip.
                assign
                v-permarj1 = v-godmarj12 / v-godmarj11 * 1200.
            end.
            if wrk3.p = 12 then do:
                put stream v-out  unformatted "<TR> <TD align=""left""></TD>" skip
                    "<TD align=""left""><B>" wrk3.nname "</B></TD>" skip
                    "<TD align=""right""></TD>" skip
                    "<TD align=""right""></TD>" skip.
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(v-permarj1 / month(dt),'->>>>>>>>>>>9.99%')),'.',',') "</B></TD>" skip.
            end.
        end.
        else do:
            if wrk3.p = 1 or wrk3.p = 2 then do:
                v-totsum3 = v-totsum3 + ((wrk3.av_saldo1) / 1000).
                v-totsum4 = v-totsum4 + ((wrk3.av_saldo3) / 1000).
                put stream v-out  unformatted "<TR> <TD align=""left""></TD>" skip
                    "<TD align=""left"">" wrk3.nname "</TD>" skip
                    "<TD align=""right"">" replace(trim(string((wrk3.av_saldo1) / 1000,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                    "<TD align=""right"">" replace(trim(string((wrk3.av_saldo3) / 1000,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip.
                if wrk3.av_saldo1 = 0 then do:
                    put stream v-out  unformatted
                    "<TD align=""right"">" replace(trim(string(0,'->>>>>>>>>>>9.99%')),'.',',') "</TD>" skip.
                end.
                else do:
                    put stream v-out  unformatted
                    "<TD align=""right"">" replace(trim(string((((wrk3.av_saldo3) / 1000) /
                    ((wrk3.av_saldo1) / 1000)) * 1200,'->>>>>>>>>>>9.99%')),'.',',') "</TD>" skip.
                end.
            end.
            if wrk3.p = 3 then do:
                v-totsum7 = v-totsum7 + v-totsum3.
                v-totsum8 = v-totsum8 + v-totsum4.
                put stream v-out  unformatted "<TR> <TD align=""left""></TD>" skip
                    "<TD align=""left""><B>" wrk3.nname "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(v-totsum3,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(v-totsum4,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip.
                if v-totsum3 = 0 then do:
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(0,'->>>>>>>>>>>9.99%')),'.',',') "</B></TD>" skip.
                end.
                else do:
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(((v-totsum4) / (v-totsum3)) * 1200,'->>>>>>>>>>>9.99%')),'.',',') "
                    </B></TD>" skip.
                end.
            end.
            if wrk3.p = 4 or wrk3.p = 5 or wrk3.p = 6 or wrk3.p = 7 or wrk3.p = 8 then do:
                v-totsum7 = v-totsum7 + ((wrk3.av_saldo1) / 1000).
                v-totsum8 = v-totsum8 + ((wrk3.av_saldo3) / 1000).
                put stream v-out  unformatted "<TR> <TD align=""left""></TD>" skip
                    "<TD align=""left"">" wrk3.nname "</TD>" skip
                    "<TD align=""right"">" replace(trim(string((wrk3.av_saldo1) / 1000,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                    "<TD align=""right"">" replace(trim(string((wrk3.av_saldo3) / 1000,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip.
                if wrk3.av_saldo1 = 0 then do:
                    put stream v-out  unformatted
                    "<TD align=""right"">" replace(trim(string(0,'->>>>>>>>>>>9.99%')),'.',',') "</TD>" skip.
                end.
                else do:
                    put stream v-out  unformatted
                    "<TD align=""right"">" replace(trim(string((((wrk3.av_saldo3) / 1000) /
                    ((wrk3.av_saldo1) / 1000)) * 1200,'->>>>>>>>>>>9.99%')),'.',',') "</TD>" skip.
                end.
            end.
            if wrk3.p = 9 then do:
                put stream v-out  unformatted "<TR> <TD align=""left""></TD>" skip
                    "<TD align=""left""><B>" wrk3.nname "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(v-totsum7,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(v-totsum8,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip.
                if v-totsum7 = 0 then do:
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(0,'->>>>>>>>>>>9.99%')),'.',',') "</B></TD>" skip.
                end.
                else do:
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(((v-totsum8) / (v-totsum7)) * 1200,'->>>>>>>>>>>9.99%')),'.',',') "
                    </B></TD>" skip.
                end.
                assign
                v-aktobyaz42 = v-totsum7
                v-aktobyaz52 = v-totsum8
                v-aktobyaz62 = ((v-totsum8) / (v-totsum7)) * 1200.
            end.
            if wrk3.p = 10 then do:
                put stream v-out  unformatted "<TR> <TD align=""left""></TD>" skip
                    "<TD align=""left""><B>" wrk3.nname "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(v-aktobyaz41 - v-aktobyaz42,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip
                    "<TD align=""right""><B>" replace(trim(string(v-aktobyaz51 - v-aktobyaz52,'->>>>>>>>>>>9.99')),'.',',') "</B></TD>" skip.
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(v-aktobyaz61 - v-aktobyaz62,'->>>>>>>>>>>9.99%')),'.',',') "</B></TD>" skip.
                assign
                v-godmarj22 = v-aktobyaz51 - v-aktobyaz52.
            end.
            if wrk3.p = 11 then do:
                put stream v-out  unformatted "<TR> <TD align=""left""></TD>" skip
                    "<TD align=""left""><B>" wrk3.nname "</B></TD>" skip
                    "<TD align=""right""></TD>" skip
                    "<TD align=""right""></TD>" skip.
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(v-godmarj22 / v-godmarj21 * 1200,'->>>>>>>>>>>9.99%')),'.',',') "
                    </B></TD>" skip.
                assign
                v-permarj2 = v-godmarj22 / v-godmarj21 * 1200.
            end.
            if wrk3.p = 12 then do:
                put stream v-out  unformatted "<TR> <TD align=""left""></TD>" skip
                    "<TD align=""left""><B>" wrk3.nname "</B></TD>" skip
                    "<TD align=""right""></TD>" skip
                    "<TD align=""right""></TD>" skip.
                    put stream v-out  unformatted
                    "<TD align=""right""><B>" replace(trim(string(v-permarj2 / month(dt),'->>>>>>>>>>>9.99%')),'.',',') "</B></TD>" skip.
            end.
        end.
    end.

    put stream v-out unformatted "</table>".
    put stream v-out unformatted
    "<P></P>" skip
    "<P></P>" skip
    "<P><FONT size = 1>Допускается отклонение от фактических данных +/- 0,5%</FONT></P>" skip.

    output stream v-out close.
    if v-option <> "mail" then unix silent value("cptwin repbonus.html excel").
    empty temp-table wrk.
    empty temp-table wrk1.
    empty temp-table wrk2.
    empty temp-table wrk3.
return.

vres = yes.

