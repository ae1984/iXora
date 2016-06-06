/* cifrep4.p

 * MODULE

 * DESCRIPTION

 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT

 * MENU
        Перечень пунктов Меню Прагмы
 * BASES
        BANK COMM
 * AUTHOR
        28/09/2011 evseev
 * CHANGES


*/

{global.i}

def var CurCat as char.
def buffer b-cif for cif.
def buffer b-aaa for aaa.
def buffer b-lgr for lgr.
def var dt1 as date no-undo.
def var dt2 as date no-undo.
def var err as char init "".
def var unknown as deci init 0.
def var LN as char extent 8 initial ["[-|-]","[-/-]","[---]","[-\\-]","[-|-]","[-/-]","[---]","[-\\-]"].
def var i as int init 1.
def var rt as int init 0.
def var repname as char init "".
def var v-result as char init "".
def var v-amt as deci init 0.
def var CatName as char init "".
def var allcat as logical init no.
def var all-cif as logical init yes.
def var one-cif as char.


define temp-table wrk
       field cif        as char    /*Код клиента*/
       field trw        as char    /*Категория клиента*/
       field jame       as char    /*СП*/
       field namesp     as char    /*наименование сп*/
       field comm-cred  as deci    /*Комиссии по выданным кредитам*/
       field supp-cred  as deci    /*% доход по кредитам*/
       field kass-oper  as deci    /*Кассовые операции*/
       field send-kz    as deci    /*Переводные операции в тенге*/
       field send-val   as deci    /*Переводные операции в ин.  валюте*/
       field conv-oper  as deci    /*Конвертация*/
       field doc-oper   as deci    /*Документарные операции*/
       field garan-oper as deci    /*Гарантии*/
       field other-oper as deci    /*Прочие комиссии*/
       field curs-doh   as deci    /*Курсовой доход*/
       field itog       as deci.   /*Итого*/

define temp-table gl_wrk
            field type as int
            field gl as int
            field tarcod as char
            field name as char
            field crc as int.


/**************************************************************************************/
function GetCatName returns char ( input code as char ):
  /*
  find first codfr where codfr.codfr = 'cifkat' and codfr.code = code no-lock no-error.
  if avail codfr then return codfr.name[1].
  else return codfr.code.
  */
  find first ppoint where ppoint.point = integer(entry(1,code)) and ppoint.dep = integer(entry(2,code)) no-lock no-error.
  if avail ppoint then return ppoint.name.
  else return code.
end function.
/**************************************************************************************/
function GetNormSumm returns char (input summ as deci):
   def var ss1 as deci.
   def var ret as char.
   if summ >= 0 then
   do:
    ss1 = summ.
    ret = string(ss1,">>>>>>>>>>>>>>>>9.99").
   end.
   else do:
    ss1 = - summ.
   ret = "-" + trim(string(ss1,">>>>>>>>>>>>>>>>9.99")).
   end.
   return trim(ret).
end function.
/****************************************************************************************************************/
function GetDate returns char ( input dt as date):
  return replace(string(dt,"99/99/9999"),"/",".").
end function.
/****************************************************************************************************************/
define frame fr
   skip(1)
   dt1      label 'C ' format '99/99/9999'
   dt2      label ' ПО' format '99/99/9999' skip
   with centered side-label row 5 title "УКАЖИТЕ ПЕРИОД ОТЧЕТА".

   dt1 = g-today. dt2 = g-today.

   update dt1 dt2 with frame fr.
   hide frame fr.


/**************************************************************************************/
define frame fr_cif
   skip(1)
   all-cif  label 'Все клиенты (Yes)/Один клиент (NO)'
   with centered side-label row 5 title "ВЫБЕРИТЕ КАТЕГОРИЮ".

   update all-cif with frame fr_cif.
   hide frame fr_cif.

/**************************************************************************************/
define frame fr_onecif
   skip(1)
   one-cif  label 'Клиент'
   with centered side-label row 5 title "ВВЕДИТЕ КОД КЛИЕНТА".

   if all-cif = no then do:
       update one-cif with frame fr_onecif.
       hide frame fr_onecif.
   end.

/**************************************************************************************/
function GetTypeCod returns int (input code as char ,input r-jh as int ):
    def buffer b-gl_wrk for gl_wrk.
    find first b-gl_wrk where b-gl_wrk.tarcod = trim(code) no-lock no-error.
    if avail b-gl_wrk then return b-gl_wrk.type.
    else do:
        /*Message "Не найден код тарифа " code " в справочнике gl_wrk!"  view-as alert-box.*/
        err = err + "Не найден код тарифа " + code + " для проводки " + string(r-jh) + "\r\n".
        rt = rt + 1.
        return 0.
    end.
end function.
/**************************************************************************************/
function GetType returns int (input agl as int,input r-jh as int):
    def var curtype as int init -1.
    def buffer b-remtrz for remtrz.
    def buffer b-joudoc for joudoc.
    def buffer b-gl_wrk for gl_wrk.

    find first b-gl_wrk where b-gl_wrk.gl = agl no-lock no-error.
    if avail b-gl_wrk then do:
    /*for each b-gl_wrk where b-gl_wrk.gl = agl no-lock:
        if curtype = -1 then curtype = b-gl_wrk.type.
        if curtype <> b-gl_wrk.type  then do: /*Неоднозначное определение группы комисcии*/ */
            find first b-remtrz where  b-remtrz.valdt2 <= dt2 and b-remtrz.valdt2 >= dt1 and  b-remtrz.jh1 = r-jh no-lock no-error.
            if avail b-remtrz then do:
                curtype = GetTypeCod ( string (b-remtrz.svccgr) , r-jh).
                if curtype = 0 then do: err = err + "Найден RMZ " + b-remtrz.remtrz + "  проводка:" + string(r-jh) + " код комиссии:" + string (b-remtrz.svccgr) + "\r\n". rt = rt + 1. end.
            end.
            else do:
                find first b-joudoc where  b-joudoc.whn >= dt1 and b-joudoc.whn <= dt2 and  b-joudoc.jh = r-jh no-lock no-error.
                if avail b-joudoc then do:
                    curtype = GetTypeCod ( string (b-joudoc.comcode) , r-jh).
                    if curtype = 0 then do: err = err + "Найден JOU " + b-joudoc.docnum + "  проводка:" + string(r-jh) + " код комиссии - " + string (b-joudoc.comcode) + "\r\n". rt = rt + 1. end.
                end.
            end.
          /*  leave.
        end.
    end.*/
    end.
    /* message string(curtype) view-as alert-box. */
    return curtype.
end function.
/**************************************************************************************/
function Convcrc returns decimal ( input sum as decimal, input c1 as int, input c2 as int, input d1 as date):
 define buffer bcrc1 for crchis.
 define buffer bcrc2 for crchis.
    if c1 <> c2 then
       do:
          find last bcrc1 where bcrc1.crc = c1 and bcrc1.rdt <= d1 no-lock no-error.
          find last bcrc2 where bcrc2.crc = c2 and bcrc2.rdt <= d1 no-lock no-error.
          if avail bcrc1 and avail bcrc2 then return sum * bcrc1.rate[1] / bcrc2.rate[1].
       end.
    else return sum.
end function.
/**************************************************************************************/
function GetCifName return char (input tcif as char):
    find first cif where cif.cif = tcif no-lock no-error.
    if avail cif then return cif.prefix + " " + cif.name.
    else return tcif.
end function.
/**************************************************************************************/
/*function GetCifType return char (input tcif as char):
    find first cif where cif.cif = tcif no-lock no-error.
    if avail cif then return cif.type.
    else return tcif.
end function.*/
/**************************************************************************************/
/*function GetCifKat return char (input tcif as char):
    find first cif where cif.cif = tcif no-lock no-error.
    if avail cif then do:
        find first codfr where codfr.codfr = 'cifkat' and codfr.code = cif.trw no-lock no-error.
        if avail codfr then do:
            return codfr.name[1].
        end.
    end.
    else return tcif.
end function.*/
/**************************************************************************************/
/**************************************************************************************/

function GetCifProfC return char (input tcif as char):
    find first cif where cif.cif = tcif no-lock no-error.
    if avail cif then do:
        find first sub-cod where sub-cod.sub = "cln" and sub-cod.acc = tcif and sub-cod.d-cod = 'sproftcn' no-lock no-error.
        if avail sub-cod then do:
           find first codfr where codfr.codfr = "sproftcn" and codfr.code = sub-cod.ccode no-lock no-error.
           if avail codfr then do:
               if codfr.code <> "" then return codfr.name[1].
               else return "-".
           end.
        end.
        else return "-".
    end.
    else return "-".
end function.
/**************************************************************************************/
function GetSuppCred returns decimal ( input tcif as char ):
    def var summ as deci init 0.
    for each lon where lon.cif = tcif no-lock .
        for each lonres where lonres.jdt >= dt1 and lonres.jdt <= dt2 and lonres.lon = lon.lon and lonres.dc = 'c' and ( lonres.lev = 2 or lonres.lev = 16 ) no-lock:
            if lonres.crc = 1 then summ = summ + lonres.amt.
            else summ = summ + Convcrc(lonres.amt , lonres.crc , 1 , lonres.jdt ).
        end.
    end.
    return summ.
end function.
/**************************************************************************************/

/*для теста*/
/*def stream rep.*/

/**************************************************************************************/

function CreateRec returns int ( input cif as char , input acc as char ,
				                 output comm-cred  as deci ,
				                 output kass-oper  as deci ,
				                 output send-kz    as deci ,
				                 output send-val   as deci ,
				                 output conv-oper  as deci ,
				                 output doc-oper   as deci ,
				                 output garan-oper as deci ,
				                 output other-oper as deci ):

/**********************************TEST****************************************************/
/*
output stream rep to value("rpt_cifrep3" + cif + ".htm").
put stream rep "<html><head><title>Платежи Авангард-Plat</title>" skip
                       "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                       "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.
put stream rep unformatted "<tr>" skip.
       put stream rep unformatted "<td> Проводки по клиенту " cif " счет " acc "</td>" skip.
       put stream rep unformatted "</tr>" skip.

put stream rep unformatted
            "<table border=1 cellpadding=0 cellspacing=0>" skip
            "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
            "<td width=120> № проводки </td>" skip
            "<td width=200> Описание </td>" skip
            "<td width=200> Сумма </td>" skip.
put stream rep unformatted "</tr>" skip.
*/
/**********************************TEST****************************************************/


    def buffer b-jl for jl.
    for each jl where jl.acc = acc and jl.dc = "D" and jl.jdt >= dt1 and jl.jdt <= dt2  /*jl.dam > 0*/ no-lock by jl.jh:
        find first jh where jh.jh = jl.jh and jh.party begins "Storn" no-lock no-error.
        if avail jh then next.
        find first b-jl where b-jl.jh = jl.jh and  b-jl.ln = jl.ln + 1 and b-jl.jdt = jl.jdt and b-jl.dc = "C" no-lock no-error.
        if avail b-jl then do:
          /*if all-cif = yes then do:*/
            case GetType(b-jl.gl,b-jl.jh):
                when -1 then do:
                    /* г.к. не из нашего списка */
                    next.
                end.
                when 0 then do:
                    /*Так и не нашли куда это отнести :(*/
                    err = err + "Невозможно определить группу для проводки "  + string(b-jl.jh) + " на сумму:" +  GetNormSumm( b-jl.cam ) +  "\r\n".
                    if b-jl.crc = 1 then unknown = unknown + b-jl.cam.
                    else unknown = unknown + Convcrc(b-jl.cam , b-jl.crc , 1 , b-jl.jdt ).
                end.
                when 1 then do: /*Комиссии по выданным кредитам*/
                    if b-jl.crc = 1 then comm-cred = comm-cred + b-jl.cam.
                    else comm-cred = comm-cred + Convcrc(b-jl.cam , b-jl.crc , 1 , b-jl.jdt ).
                end.
                when 2 then do: /*Кассовые операции*/
                    if b-jl.crc = 1 then kass-oper = kass-oper + b-jl.cam.
                    else kass-oper = kass-oper + Convcrc(b-jl.cam , b-jl.crc , 1 , b-jl.jdt ).
                end.
                when 3 then do:  /*Переводные операции в тенге */
                    if b-jl.crc = 1 then send-kz = send-kz + b-jl.cam.
                    else send-kz = send-kz + Convcrc(b-jl.cam , b-jl.crc , 1 , b-jl.jdt ).
                end.
                when 4 then do:  /*Переводные операции в валюте */
                    if b-jl.crc = 1 then send-val = send-val + b-jl.cam.
                    else send-val = send-val + Convcrc(b-jl.cam , b-jl.crc , 1 , b-jl.jdt ).
                    /*
                      put stream rep unformatted "<tr>" skip.
                      put stream rep unformatted "<td>" string(b-jl.jh) " валюта - " string(b-jl.crc) "</td>" skip.
                      put stream rep unformatted "<td>" b-jl.rem[1] + b-jl.rem[2] + b-jl.rem[3] + b-jl.rem[4] + b-jl.rem[5] "</td>" skip.
                      put stream rep unformatted "<td>" string(b-jl.cam ,">>>,>>>,>>>,>>>.99-") "</td>" skip.
                      put stream rep unformatted "</tr>" skip.
                    */
                end.
                when 5 then do: /*Конвертация*/
                    if b-jl.crc = 1 then conv-oper = conv-oper + b-jl.cam.
                    else conv-oper = conv-oper + Convcrc(b-jl.cam , b-jl.crc , 1 , b-jl.jdt ).
                end.
                when 6 then do: /*Документарные операции*/
                    if b-jl.crc = 1 then doc-oper = doc-oper + b-jl.cam.
                    else doc-oper = doc-oper + Convcrc(b-jl.cam , b-jl.crc , 1 , b-jl.jdt ).
                end.
                when 7 then do: /*Гарантии*/
                    if b-jl.crc = 1 then garan-oper = garan-oper + b-jl.cam.
                    else garan-oper = garan-oper + Convcrc(b-jl.cam , b-jl.crc , 1 , b-jl.jdt ).
                end.
                when 8 then do: /*Прочие комиссии*/
                    /*  message "b-jl.jh=" b-jl.jh "cif=" cif "b-jl.cam=" b-jl.cam view-as alert-box.*/
                    if b-jl.crc = 1 then other-oper = other-oper + b-jl.cam.
                    else other-oper = other-oper + Convcrc(b-jl.cam , b-jl.crc , 1 , b-jl.jdt ).
                end.
            end case.
          /*end.*/ /* if all-cif = yes */
        end.
    end.

    /**********************************TEST****************************************************/
    /*
    put stream rep unformatted "</table></body></html>" skip.
    output stream rep close.
    if send-val > 0 then unix silent value("cptwin rpt_cifrep3" + cif + ".htm excel").
    */
    /**********************************TEST****************************************************/

 return 0.
end function.

/**************************************************************************************/

 run LoadGL.

/*
output to gl.txt.
for each gl_wrk :
put unformatted  gl_wrk.type ";"  gl_wrk.gl format "zzzzzz" ";" gl_wrk.tarcod ";" gl_wrk.name format "x(80)"  ";" gl_wrk.crc skip.
end.
output close.
pause.
*/

{comm-txb.i}

if all-cif = yes then run splist(0).
CurCat = return-value.
if CurCat = "EXIT" then return.

repname = "form3_" + comm-txb() + "_" + CurCat + "_" +   replace(string(dt1,"99/99/9999"),"/","-") + "_" +  replace(string(dt2,"99/99/9999"),"/","-") + ".html".
repname = replace(repname," ","_").
repname = replace(repname,'"',"").

/*input through cptwin value("/data/reports/categ/" + repname) iexplore.
repeat:
    import v-result.
end.

if v-result = "" then do:*/
/*все ок, отчет уже есть*/
/*return.
end.*/

/* b-cif.cif = "A12115" and b-cif.cif = "T13502" and*/

def buffer bjl for jl.
def var v-s as char.
if all-cif = yes then do:
/*================================================  ALL */
if CurCat = "ALL" then do:
    AllCat = yes.
    /*for each ppoint no-lock:*/

        /*CurCat = string(ppoint.point) + "," + string(ppoint.dep).*/

        for each b-cif where  b-cif.type = "B" /*b-cif.del = no*/ no-lock by b-cif.cif:

            for each b-aaa where b-aaa.cif = b-cif.cif and b-aaa.regdt <= dt2  no-lock:
                find b-lgr where b-lgr.lgr = b-aaa.lgr and b-lgr.led <> "oda" no-lock no-error.
                if avail b-lgr then do:
                    if b-aaa.sta = 'c' then do:
                        find first sub-cod where sub-cod.sub = 'cif' and sub-cod.acc = b-aaa.aaa and sub-cod.d-cod = 'clsa' no-lock no-error.
                        if avail sub-cod then do:
                            if sub-cod.rdt < dt1 then next.
                        end.
                        else next.
                    end.
                    create wrk.
                         wrk.cif = b-aaa.cif.
                         wrk.trw = b-cif.trw.
                         wrk.jame = b-cif.jame.
                         wrk.namesp = GetCifProfC(b-aaa.cif).
                         wrk.supp-cred = GetSuppCred( b-aaa.cif).
                         CreateRec( wrk.cif , b-aaa.aaa ,
                                   wrk.comm-cred ,
                                   wrk.kass-oper ,
                                   wrk.send-kz ,
                                   wrk.send-val ,
                                   wrk.conv-oper ,
                                   wrk.doc-oper ,
                                   wrk.garan-oper ,
                                   wrk.other-oper).
                    curs-doh = 0. /*DAMIR*/
                    for each jl where jl.acc = b-aaa.aaa and jl.dc = "c" and jl.jdt >= dt1 and jl.jdt <= dt2 and jl.sub = "cif"  no-lock:

                        find first bjl where bjl.jh = jl.jh and bjl.gl = 287044 no-lock no-error.
                        if not avail bjl then next.
                        /*find first bjl where bjl.jh = jl.jh and bjl.gl = 287045 no-lock no-error.
                        if not avail bjl then next.*/
                        find first bjl where bjl.jh = jl.jh and bjl.gl = 453010 no-lock no-error.
                        if avail bjl then  do:
                            if bjl.crc = 1 then curs-doh = curs-doh + bjl.cam.
                            else curs-doh = curs-doh + Convcrc(bjl.cam , bjl.crc , 1 , bjl.jdt ).
                        end.
                    end.
                    wrk.curs-doh = curs-doh.
                    wrk.itog =   wrk.supp-cred + wrk.comm-cred + wrk.kass-oper + wrk.send-kz + wrk.send-val + wrk.conv-oper + wrk.doc-oper + wrk.garan-oper +
                                 wrk.other-oper + curs-doh.
                end.
                hide message no-pause.
                message "Сбор данных - " LN[i] " " b-aaa.cif.
                if i = 8 then i = 1.
                else i = i + 1.
            end. /*for each b-aaa*/
        end. /*for each b-cif*/
   /* end.*/
end.
/*================================================   <> ALL */
else do:
    for each b-cif where b-cif.del = no and caps(b-cif.type) = "B" /*and b-cif.cif = "R10547"*/ no-lock by b-cif.cif:
        v-s = GetCifProfC (b-cif.cif).
        if CurCat <> v-s then next.
    /* if CurCat <> "ALL" and b-cif.trw <> CurCat then next. */
        for each b-aaa where b-aaa.cif = b-cif.cif and b-aaa.regdt <= dt2 /*and b-aaa.sta <> "E" and b-aaa.sta <> "C"*/ no-lock:
        /*message b-aaa.aaa view-as alert-box.*/
            find b-lgr where b-lgr.lgr = b-aaa.lgr and b-lgr.led <> "oda" no-lock no-error.
            if avail b-lgr then do:
                if b-aaa.sta = 'c' then do:
                    find first sub-cod where sub-cod.sub = 'cif' and sub-cod.acc = b-aaa.aaa and sub-cod.d-cod = 'clsa' no-lock no-error.
                    if avail sub-cod then do:
                        if sub-cod.rdt < dt1 then next.
                    end.
                    else next.
                end.
                create wrk.
                     wrk.cif = b-aaa.cif.
                     wrk.trw = b-cif.trw.
                     wrk.jame = b-cif.jame.
                     wrk.namesp = CurCat.
                     wrk.supp-cred = GetSuppCred( b-aaa.cif).
                     CreateRec( wrk.cif , b-aaa.aaa ,
                                      wrk.comm-cred ,
                                      wrk.kass-oper ,
                                      wrk.send-kz ,
                                      wrk.send-val ,
                                      wrk.conv-oper ,
                                      wrk.doc-oper ,
                                      wrk.garan-oper ,
                                      wrk.other-oper ).
            curs-doh = 0. /*DAMIR*/

            /*def buffer bjl for jl.*/
            for each jl where jl.acc = b-aaa.aaa and jl.dc = "c" and jl.jdt >= dt1 and jl.jdt <= dt2 and jl.sub = "cif"   no-lock:
                find first bjl where bjl.jh = jl.jh and bjl.gl = 287044 no-lock no-error.
                if not avail bjl then next.
                /*find first bjl where bjl.jh = jl.jh and bjl.gl = 287045 no-lock no-error.
                if not avail bjl then next.*/
                find first bjl where bjl.jh = jl.jh and bjl.gl = 453010 no-lock no-error.
                if avail bjl then  do:
                    if bjl.crc = 1 then curs-doh = curs-doh + bjl.cam.
                    else curs-doh = curs-doh + Convcrc(bjl.cam , bjl.crc , 1 , bjl.jdt ).
                end.
            end.
            wrk.curs-doh = curs-doh.
            wrk.itog =   wrk.supp-cred + wrk.comm-cred + wrk.kass-oper + wrk.send-kz + wrk.send-val + wrk.conv-oper + wrk.doc-oper + wrk.garan-oper +
                         wrk.other-oper + curs-doh.
        end.

                            hide message no-pause.
                            message "Сбор данных - " LN[i] " " b-aaa.cif.
                            if i = 8 then i = 1.
                            else i = i + 1.
        end. /*for each b-aaa*/
    end. /*for each b-cif*/
end.
/*================================================*/
end. /*if all-cif = yes*/
/*================================================ one-cif*/
if all-cif = no then do:
        for each b-aaa where b-aaa.cif = one-cif and b-aaa.regdt <= dt2 /*and b-aaa.sta <> "E" and b-aaa.sta <> "C"*/ no-lock:
           /*message b-aaa.aaa view-as alert-box.*/
            find b-lgr where b-lgr.lgr = b-aaa.lgr and b-lgr.led <> "oda" no-lock no-error.
            if avail b-lgr then do:
                find first b-cif where b-cif.cif = one-cif no-lock no-error.
                if b-aaa.sta = 'c' then do:
                    find first sub-cod where sub-cod.sub = 'cif' and sub-cod.acc = b-aaa.aaa and sub-cod.d-cod = 'clsa' no-lock no-error.
                    if avail sub-cod then do:
                        if sub-cod.rdt < dt1 then next.
                    end.
                    else next.
                end.
                create wrk.
                     wrk.cif = b-aaa.cif.
                     wrk.jame = b-cif.jame.
                     wrk.namesp = GetCifProfC(b-aaa.cif).
                     wrk.trw = b-cif.trw.
                     wrk.supp-cred = GetSuppCred( b-aaa.cif).
                     CreateRec( wrk.cif , b-aaa.aaa ,
                                wrk.comm-cred ,
                                wrk.kass-oper ,
                                wrk.send-kz ,
                                wrk.send-val ,
                                wrk.conv-oper ,
                                wrk.doc-oper ,
                                wrk.garan-oper ,
                                wrk.other-oper).

                curs-doh = 0. /*DAMIR*/

                /*def buffer bjl for jl.*/
                for each jl where  jl.acc = b-aaa.aaa and jl.dc = "c" and jl.jdt >= dt1 and jl.jdt <= dt2 and jl.sub = "cif"   no-lock:
                    find first bjl where bjl.jh = jl.jh and bjl.gl = 287044 no-lock no-error.
                    if not avail bjl then next.
                    /*find first bjl where bjl.jh = jl.jh and bjl.gl = 287045 no-lock no-error.
                    if not avail bjl then next.*/
                    find first bjl where bjl.jh = jl.jh and bjl.gl = 453010 no-lock no-error.
                    if avail bjl then  do:
                        if bjl.crc = 1 then curs-doh = curs-doh + bjl.cam.
                        else curs-doh = curs-doh + Convcrc(bjl.cam , bjl.crc , 1 , bjl.jdt ).
                    end.
                end.
                wrk.curs-doh = curs-doh.
                wrk.itog =   wrk.supp-cred + wrk.comm-cred + wrk.kass-oper + wrk.send-kz + wrk.send-val + wrk.conv-oper + wrk.doc-oper + wrk.garan-oper +
                            wrk.other-oper + curs-doh.
            end.

            hide message no-pause.
            message "Сбор данных - " LN[i] " " b-aaa.cif.
            if i = 8 then i = 1.
            else i = i + 1.
        end. /*for each b-aaa*/
end.

/*================================================*/

hide message no-pause.


run ExportFile.



v-result = "".
input through value ("mv " + repname + " /data/reports/categ/" + repname ).

repeat:
    import unformatted v-result.
end.

if v-result <> "" then do:
    message " Произошла ошибка при копировании отчета - " v-result.
end.


if unknown > 0 or rt > 0 then do:
    message "При формировании отчета произошли ошибки!~n Неопределенных платежей на сумму:" GetNormSumm( unknown ) view-as alert-box.
    output to err.txt.
    err = err + "Неопределенных платежей на сумму:" + GetNormSumm( unknown ) + "\r\n".
    put unformatted err.
    output close.
    unix silent cptwin err.txt notepad.
end.

/***************************************************************************************************************/
procedure ExportFile.
    output to value(repname).
    {html-title.i}

    def var Caption as char init "Отчет по общим доходам (Наимен. клиентов)".
    def var NameBank as char.
    def buffer b-cmp for cmp.
   /* def var tmp-cif as char.*/
    find first b-cmp no-lock no-error.
    if avail b-cmp then
    do:
      NameBank = trim(b-cmp.name).
    end.

    put unformatted "<TABLE width=""100%"" cellspacing=""0"" cellpadding=""5"" border=""1"">" skip.

    put unformatted "<tr><td align=center colspan=10><font size=""4""><b><a name="" ""></a>" Caption "  " NameBank "  С " GetDate(dt1) " ПО " GetDate(dt2) "</b></font></td></tr>" skip.
  /*
    put unformatted "<TR style=""font:bold;font-size:12pt"">" skip
                            "<TD align=center colspan=10>" NameBank "</TD></TR>" skip.
    */

   if allcat = yes then do:
        CatName = "Все".
   end.
   else do:
        if all-cif = yes then CatName = GetCatName( CurCat ).
        else do:
            find first cif where cif.cif = one-cif no-lock no-error.
            find first codfr where codfr.codfr = 'cifkat' and codfr.code = cif.trw no-lock no-error.
            if avail codfr then CatName = codfr.name[1].
        end.
   end.
    put unformatted "<TR style=""font:bold;font-size:11pt"">" skip
                                "<TD>" "Профит центр: " CatName "</TD>" skip
                                /*"<TD>" "Ф/Юр" "</TD>" skip*/
                                "<TD>" "Наименование профит центра" "</TD>" skip
                                "<TD>" "Комиссии по выданным кредитам" "</TD>" skip
                                "<TD>" "% доход по кредитам" "</TD>" skip
                                "<TD>" "Кассовые операции" "</TD>" skip
                                "<TD>" "Переводные операции в тенге" "</TD>" skip
                                "<TD>" "Переводные операции в ин.валюте" "</TD>" skip
                                "<TD>" "Конвертация" "</TD>" skip
                                "<TD>" "Курсовой доход" "</TD>" skip
                                "<TD>" "Документарные операции" "</TD>" skip
                                "<TD>" "Гарантии" "</TD>" skip
                                "<TD>" "Прочие комиссии" "</TD>" skip
                                "<TD>" "ИТОГО РКО" "</TD>" skip.


    def var comm-cred  as deci init 0.
    def var supp-cred  as deci init 0.
    def var kass-oper  as deci init 0.
    def var send-kz    as deci init 0.
    def var send-val   as deci init 0.
    def var conv-oper  as deci init 0.
    def var doc-oper   as deci init 0.
    def var garan-oper as deci init 0.
    def var other-oper as deci init 0.
    def var curs-doh   as deci init 0.
    def var itog       as deci init 0.

    def var comm-cred-all  as deci init 0.
    def var supp-cred-all  as deci init 0.
    def var kass-oper-all  as deci init 0.
    def var send-kz-all    as deci init 0.
    def var send-val-all   as deci init 0.
    def var conv-oper-all  as deci init 0.
    def var doc-oper-all   as deci init 0.
    def var garan-oper-all as deci init 0.
    def var other-oper-all as deci init 0.
    def var curs-doh-all   as deci init 0.
    def var itog-all       as deci init 0.
 /*   find first wrk no-lock no-error.
    tmp-cif = wrk.cif.
   */

    for each wrk break by wrk.cif:
       /* put unformatted "<tr><td colspan=2><font size=""6""><b><a name=""" "D1" """></a>" "D2" "</b></font></td></tr>" skip.*/


            if  /*( wrk.cif <> tmp-cif ) or */ last-of( wrk.cif ) then do:
                comm-cred = comm-cred + wrk.comm-cred.
                supp-cred = supp-cred + wrk.supp-cred.
                kass-oper = kass-oper + wrk.kass-oper.
                send-kz = send-kz + wrk.send-kz.
                send-val = send-val + wrk.send-val.
                conv-oper = conv-oper + wrk.conv-oper.
                doc-oper = doc-oper + wrk.doc-oper.
                garan-oper = garan-oper + wrk.garan-oper.
                other-oper = other-oper + wrk.other-oper.
                curs-doh = curs-doh + wrk.curs-doh.
                itog = itog + wrk.itog.

                put unformatted "<TR style=""font-size:10pt"">" skip
                                "<TD>" GetCifName( wrk.cif ) "</TD>" skip
                                /*"<TD>" GetCifType( wrk.cif ) "</TD>" skip*/
                                "<TD>" /*GetCifKat( wrk.cif )*/ wrk.namesp "</TD>" skip
                                "<TD>" GetNormSumm(comm-cred) "</TD>" skip
                                "<TD>" GetNormSumm(supp-cred) "</TD>" skip
                                "<TD>" GetNormSumm(kass-oper) "</TD>" skip
                                "<TD>" GetNormSumm(send-kz) "</TD>" skip
                                "<TD>" GetNormSumm(send-val) "</TD>" skip
                                "<TD>" GetNormSumm(conv-oper) "</TD>" skip
                                "<TD>" GetNormSumm(curs-doh) "</TD>" skip
                                "<TD>" GetNormSumm(doc-oper) "</TD>" skip
                                "<TD>" GetNormSumm(garan-oper) "</TD>" skip
                                "<TD>" GetNormSumm(other-oper) "</TD>" skip
                                "<TD>" GetNormSumm(itog) "</TD>" skip.


                comm-cred-all = comm-cred-all + comm-cred.
                supp-cred-all = supp-cred-all + supp-cred.
                kass-oper-all = kass-oper-all + kass-oper.
                send-kz-all = send-kz-all + send-kz.
                send-val-all = send-val-all + send-val.
                conv-oper-all = conv-oper-all + conv-oper.
                doc-oper-all = doc-oper-all + doc-oper.
                garan-oper-all = garan-oper-all + garan-oper.
                other-oper-all = other-oper-all + other-oper.
                curs-doh-all = curs-doh-all + curs-doh.
                itog-all = itog-all + itog.
                comm-cred = 0.
                supp-cred = 0.
                kass-oper = 0.
                send-kz = 0.
                send-val = 0.
                conv-oper = 0.
                doc-oper = 0.
                garan-oper = 0.
                other-oper = 0.
                curs-doh = 0.
                itog = 0.

               /* tmp-cif = wrk.cif.                   */
            end.
            else do:
                comm-cred = comm-cred + wrk.comm-cred.
                supp-cred = supp-cred + wrk.supp-cred.
                kass-oper = kass-oper + wrk.kass-oper.
                send-kz = send-kz + wrk.send-kz.
                send-val = send-val + wrk.send-val.
                conv-oper = conv-oper + wrk.conv-oper.
                doc-oper = doc-oper + wrk.doc-oper.
                garan-oper = garan-oper + wrk.garan-oper.
                other-oper = other-oper + wrk.other-oper.
                curs-doh = curs-doh + wrk.curs-doh.
                itog = itog + wrk.itog.
            end.



           /*"<TD align=left>&nbsp;" wrk.TelNo "</TD>" skip*/

    end.

    put unformatted "<TR style=""font:bold;font-size:11pt"">" skip
                                "<TD>" "Итого" "</TD>" skip
                                "<TD></TD>" skip
                                "<TD>" GetNormSumm(comm-cred-all) "</TD>" skip
                                "<TD>" GetNormSumm(supp-cred-all) "</TD>" skip
                                "<TD>" GetNormSumm(kass-oper-all) "</TD>" skip
                                "<TD>" GetNormSumm(send-kz-all) "</TD>" skip
                                "<TD>" GetNormSumm(send-val-all) "</TD>" skip
                                "<TD>" GetNormSumm(conv-oper-all) "</TD>" skip
                                "<TD>" GetNormSumm(curs-doh-all) "</TD>" skip
                                "<TD>" GetNormSumm(doc-oper-all) "</TD>" skip
                                "<TD>" GetNormSumm(garan-oper-all) "</TD>" skip
                                "<TD>" GetNormSumm(other-oper-all) "</TD>" skip
                                "<TD>" GetNormSumm(itog-all) "</TD>" skip.

    put unformatted "</table>" .
    {html-end.i}
    output close.
    unix silent cptwin value(repname) iexplore.
    /*unix silent cptwin cifrep.html excel. */
end procedure.
/***************************************************************************************************************/

procedure LoadGL :
    empty temp-table gl_wrk.
    def buffer b-gl_wrk for gl_wrk.
    def var ktype as int.
    def var kpos as int.
    def buffer b-tarif2 for tarif2.
    def var TarCod as char extent 8 initial
                                 ["940,980", /* Комиссии по выданным кредитам*/
                                  "403,409,439,151,456,430", /*Кассовые операции */
                                  "214,215,163,019,017,202,222,111,112,147", /*Переводные операции в тенге*/
                                  "204,205,218,123", /*Переводные операции в ин.  валюте*/
                                  "804,802,808", /*Конвертация*/
                                  "970,995,996,971,997,998,999,910,972,960,961,962,963,964,965,966,967,968,969,952,953,954,955,956,957,958,959,941,942,943,944,945,946,947", /*Документарные операции*/
                                  "981,982,987,993,994,988,993,994,989,984,990,985,986", /*Гарантии*/
                                  "137,177,039,120,440,146,040,132,158,102,192,153,024,101,020,023,102,104,154,109,117"]. /*Прочие комиссии*/

    do ktype = 1 to 8:
        /* message TarCod[ktype] view-as alert-box.*/
        do kpos = 1 to NUM-ENTRIES(TarCod[ktype]):
            find first b-tarif2 where b-tarif2.num + b-tarif2.kod = trim(ENTRY(kpos,TarCod[ktype])) /* and b-tarif2.stat = 'r'*/ no-lock no-error.
            if avail b-tarif2 then do:
                /*
                find first b-gl_wrk where b-gl_wrk.gl = b-tarif2.kont and b-gl_wrk.type <> ktype no-lock no-error.
                if avail b-gl_wrk then
                do:
                message "Уже есть..." b-gl_wrk.gl "  cod = " b-gl_wrk.tarcod view-as alert-box.
                end.
                */
                create gl_wrk.
                       gl_wrk.type = ktype.
                       gl_wrk.gl = b-tarif2.kont.
                       gl_wrk.tarcod =  ENTRY(kpos,TarCod[ktype]).
                       gl_wrk.name = b-tarif2.pakalp.
                       find first gl where gl.gl = gl_wrk.gl no-lock no-error.
                       if avail gl then gl_wrk.crc = gl.crc.
            end.
            else do:
                message "Нет записей в тарификаторе с кодом " + ENTRY(kpos,TarCod[ktype]) + " !" view-as alert-box.
            end.
            /* message ENTRY(kpos,TarCod[ktype]) view-as alert-box.*/
        end.
    end.
    /*
    OUTPUT TO gl_wrk.txt.
    for each gl_wrk:
       EXPORT DELIMITER "^" gl_wrk.
    end.
    */
end procedure.