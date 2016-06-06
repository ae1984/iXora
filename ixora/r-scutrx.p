/* recpos.p 
 * MODULE
        Отчет по тразакциям scu
 * DESCRIPTION
        Отчет по переоценке внебалансовой валютной позиции
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
 * MENU
        11.9.4.1
 * BASES
        BANK 
 * AUTHOR
        26.02.2004 tsoy
 * CHANGES
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
       24.04.2004 tsoy  поменял алгоритм функции GetTurnPeriod
       19.03.2005 tsoy  убрал валидэйт
 */

{mainhead.i}

def var v-dtb as date format "99/99/9999".
def var v-dte as date format "99/99/9999".

define variable v-glc as char.

define variable v-gl  like jl.gl.
define variable v-accscu like jl.acc.

define variable v-sctrx_crccode like crc.code.
define variable v-sctrx_gl      like jl.gl.
define variable v-sctrx_turn    as deci.
define variable v-inglday       as deci.
define variable v-outglday      as deci.

define variable v-totamtcr      as deci.
define variable v-totamtdb      as deci.

def var v-cur_tot  as deci format '>>>,>>>,>>>,>>>,>>>,>>>,>>9.99' init 0.

define stream m-out.
output stream m-out to r-scutrx.html.

form 
  v-dtb  format "99/99/9999" label " Начальная дата периода " 
    help " Введите дату начала периода"
    validate (v-dtb <= g-today, " Дата не может быть больше " + string (g-today)) skip 

  v-dte  format "99/99/9999" label " Конечная дата периода  " 
    help " Введите дату конца периода"
    validate (v-dte <= g-today, " Дата не может быть больше " + string (g-today)) skip 

  v-glc   label " СчетГК    " 
    help " Введите счет главной книги" skip

  
  v-accscu label " Счет SCU  " 
    help " Введите счет SCU Help F2" 
    validate(can-find(scu where scu.scu = v-accscu), "Не существует счет") skip
  with overlay width 78 centered row 6 side-label title " Параметры отчета "  frame f-period.


def temp-table sctrx
    field sctrx_date       like glday.gdt
    field sctrx_jh         like jl.jh
    field sctrx_db         like jl.dam
    field sctrx_cr         like jl.cam
    field sctrx_who        like jl.who
    field sctrx_rem        like jl.rem[1]
    field sctrx_lev        like jl.lev
    field sctrx_gl         like jl.gl
    field sctrx_crccode    like crc.code
    field sctrx_crc        like crc.crc
    field sctrx_turn       as   deci.


/*
 * Функция возвращет обороты от начала до заданной даты
*/
function  GetTurnPeriod returns decimal( p_date as date,
                                        p_lev  as integer,
                                        p_crc  as integer,
                                        p_scu  as char
                                      ).
 
    def var v_ret as deci.
    v_ret = 0.
    
    find first scu where scu.scu = p_scu no-lock no-error.
    if avail scu and scu.rdt = g-today then
        return v_ret.

    for each jl where jl.acc = p_scu
                      and  jl.jdt <= p_date - 1
                      no-lock:

       if jl.lev = p_lev and jl.crc = p_crc then do:
                 
                 find first gl where gl.gl = jl.gl no-lock no-error.           
              
                 if avail  gl then do:
       
                      if (caps(gl.type) = "a" or caps(gl.type) = "e") then
                         v_ret = v_ret + (jl.dam - jl.cam).
                      else
                         v_ret = v_ret + (jl.cam - jl.dam).
                 end.
       end.
    end.

return v_ret.

end function.



/* BEGIN */
v-dtb = g-today.
v-dte = g-today.

update v-dtb v-dte v-glc v-accscu with frame f-period.

v-gl = inte(v-glc).

find first gl where gl.gl    = v-gl no-lock no-error.
find first scu where scu.scu = v-accscu no-lock no-error.

/*
if v-accscu <> "" then do:
    do while not avail scu: 
        find first scu where scu.scu = v-accscu no-lock no-error.
        if not avail scu then do:
            message skip " Неправильный счет " v-accscu skip(1) 
              view-as alert-box button ok title " ВНИМАНИЕ ! ". 
            update v-accscu with frame f-period.        
        end.
    end.
end.
*/
if not (avail scu) and (v-glc<>"")  then do:
      for each jl where jl.jdt >=v-dtb
                        and jl.jdt <=v-dte
                        and jl.gl = gl.gl  no-lock .

             find first crc where crc.crc = jl.crc no-lock no-error.           
             if avail crc then 
                 v-sctrx_crccode = crc.code.

             find first gl where gl.gl = jl.gl no-lock no-error.           
             if avail  gl then do:
                  v-sctrx_gl = gl.gl.
                  if (caps(gl.type) = "a" or caps(gl.type) = "e") then
                     v-sctrx_turn = jl.dam - jl.cam.
                  else
                     v-sctrx_turn = jl.cam - jl.dam.
             end.

             create sctrx.
             assign
                   sctrx_date    = jl.jdt
                   sctrx_jh      = jl.jh
                   sctrx_db      = jl.dam
                   sctrx_cr      = jl.cam
                   sctrx_who     = jl.who
                   sctrx_rem     = jl.rem[1]
                   sctrx_lev     = jl.lev
                   sctrx_gl      = v-sctrx_gl
                   sctrx_crccode = v-sctrx_crccode
                   sctrx_crc     = jl.crc
                   sctrx_turn    = v-sctrx_turn.
      end.
end.

if   (v-glc="") and (avail scu)  then do:


      for each jl where jl.jdt >=v-dtb
                        and jl.jdt <=v-dte
                        and jl.acc = scu.scu  no-lock .

             find first crc where crc.crc = jl.crc no-lock no-error.           
             if avail crc then 
                 v-sctrx_crccode = crc.code.

             find first gl where gl.gl = jl.gl no-lock no-error.           
             if avail  gl then do:
                  v-sctrx_gl = gl.gl.
                  if (caps(gl.type) = "a" or caps(gl.type) = "e") then
                     v-sctrx_turn = jl.dam - jl.cam.
                  else
                     v-sctrx_turn = jl.cam - jl.dam.
             end.

                    create sctrx.
                    assign
                         sctrx_date    = jl.jdt
                         sctrx_jh      = jl.jh
                         sctrx_db      = jl.dam
                         sctrx_cr      = jl.cam
                         sctrx_who     = jl.who
                         sctrx_rem     = jl.rem[1]
                         sctrx_lev     = jl.lev
                         sctrx_gl      = v-sctrx_gl
                         sctrx_crccode = v-sctrx_crccode
                         sctrx_crc     = jl.crc
                         sctrx_turn    = v-sctrx_turn.
      end.
end.


if    (avail scu) and (v-glc<>"")  then do:
      for each jl where jl.acc = scu.scu
                        and jl.jdt >=v-dtb
                        and jl.jdt <=v-dte
                        and jl.gl = gl.gl  no-lock .

             find first crc where crc.crc = jl.crc no-lock no-error.           
             if avail crc then 
                 v-sctrx_crccode = crc.code.

             find first gl where gl.gl = jl.gl no-lock no-error.           
             if avail  gl then do:
                  v-sctrx_gl = gl.gl.
                  if (caps(gl.type) = "a" or caps(gl.type) = "e") then
                     v-sctrx_turn = jl.dam - jl.cam.
                  else
                     v-sctrx_turn = jl.cam - jl.dam.
             end.

             create sctrx.
             assign
                   sctrx_date    = jl.jdt
                   sctrx_jh      = jl.jh
                   sctrx_db      = jl.dam
                   sctrx_cr      = jl.cam
                   sctrx_who     = jl.who
                   sctrx_rem     = jl.rem[1]
                   sctrx_lev     = jl.lev
                   sctrx_gl      = v-sctrx_gl
                   sctrx_crccode = v-sctrx_crccode
                   sctrx_crc     = jl.crc
                   sctrx_turn    = v-sctrx_turn.
      end.
end.



put stream m-out unformatted "<html><head><title>TEXAKABANK</title>" 
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" 
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream m-out unformatted "<h3><center>Транзакции по счетам SCU</center><br>" skip
                             "Счет ГК&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" v-glc  "<br>" skip
                             "Счет SCU  " string(v-accscu) "<br>" skip
                             v-dtb " по " v-dte "</h3><br>" skip.

put stream m-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0""
                                    style=""border-collapse: collapse"">" skip. 
for each sctrx break by sctrx_lev by sctrx_crc by sctrx_date:

      accumulate sctrx.sctrx_turn (TOTAL by sctrx.sctrx_lev by sctrx.sctrx_crc).
      accumulate sctrx.sctrx_db (TOTAL by sctrx.sctrx_lev by sctrx.sctrx_crc).
      accumulate sctrx.sctrx_cr (TOTAL by sctrx.sctrx_lev by sctrx.sctrx_crc).


      if first-of(sctrx.sctrx_crc) then do:
          v-inglday = 0.

          find first gl where gl.gl = sctrx.sctrx_gl no-lock no-error.           

          v-inglday = GetTurnPeriod (  v-dtb,
                                       sctrx.sctrx_lev,
                                       sctrx.sctrx_crc,
                                       v-accscu
                                    ).

          put stream m-out  unformatted "<tr><td colspan = ""6"" align= left><b>Уровень : " string(sctrx.sctrx_lev) skip
                                        "Счет ГК: " string(gl.gl) "(" sctrx.sctrx_crccode  ") " gl.des 
                                        "<br> Входящий  остаток: " replace(trim(string(v-inglday, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",") "</b></td>" skip.

          put stream m-out unformatted "<tr style=""font:bold"">"
                            "<td bgcolor=""#C0C0C0"" align=""center"">Дата</td>"
                            "<td bgcolor=""#C0C0C0"" align=""center"">Транзакция</td>"
                            "<td bgcolor=""#C0C0C0"" align=""center"">Дебет</td>"
                            "<td bgcolor=""#C0C0C0"" align=""center"">Кредит</td>"
                            "<td bgcolor=""#C0C0C0"" align=""center"">Исполнитель </td>"
                            "<td bgcolor=""#C0C0C0"" align=""center"">Детали платежа</td>"
                            "</tr>" skip.


      end.




put stream m-out  unformatted "<tr style=""font:bold"">"
                   "<td>" sctrx_date                                                                "</td>"
                   "<td>" sctrx_jh                                                                  "</td>"  skip
                   "<td>" replace(trim(string(sctrx_db, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",")      "</td>"  skip
                   "<td>" replace(trim(string(sctrx_cr, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",")      "</td>"  skip
                   "<td>" sctrx_who                                                                 "</td>"  skip
                   "<td>" sctrx_rem                                                                 "</td>" skip
                   "</tr>" skip.

      if last-of(sctrx.sctrx_crc) then do:
          v-outglday = 0.

          v-totamtdb = ACCUM total by (sctrx.sctrx_crc) sctrx.sctrx_db.  
          v-totamtcr = ACCUM total by (sctrx.sctrx_crc) sctrx.sctrx_cr.  

          put stream m-out  unformatted "<tr><td colspan = ""2"" align= left><b>Итого:</td> " skip
          "<td>" replace(trim(string(v-totamtdb, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",")  "</td>" skip
          "<td>" replace(trim(string(v-totamtcr, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",")  "</td>" skip
          "<td colspan = ""2"" align= left></td> " skip
          "</b></td>" skip.

          v-outglday = ACCUM total by (sctrx.sctrx_crc) sctrx.sctrx_turn.  
          v-outglday = v-outglday + v-inglday.  
          put stream m-out  unformatted "<tr><td colspan = ""6"" align= left><b>Исходящий остаток: " replace(trim(string(v-outglday, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",") "</b></td>" skip.
          put stream m-out  unformatted "<tr><td colspan = ""6"" align= left></td>" skip.
      end.

end.

put stream m-out unformatted
                    "</table>". 


output stream m-out close.
unix silent cptwin r-scutrx.html excel.

