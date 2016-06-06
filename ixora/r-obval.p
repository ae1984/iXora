/* r-obval.p
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
        BANK TXB
 * AUTHOR
        31/12/99 pragma
 * CHANGES
      18/11/03 nataly добавлена проверка на счета ГК 100200, 100300
      28/02/06 nataly  поменяла  условие по joudoc.whn = jl.jdt
      23.08.06 u00124 оптимизация
      07/05/08 marinav - изменен расчет курсов
      28/05/10 id00363 - добавил возможность консолидации
      04.08.10 marinav - консолидация только ЦО
      29.03.2012 aigul - добавила ГК 100500
*/

def new shared var fdate as date no-undo.
def new shared var tdate as date no-undo.

def new shared temp-table temp
    field    dc    as    char format "x(1)"
    field    debv  like  joudoc.dramt format "zzzz,zzz,zz9.99"
    field    credv like  joudoc.dramt format "zzzz,zzz,zz9.99"
    field    crc   like  crc.crc
    field    rate  like  joudoc.srate format "zzz9.99"
    field    jh    like jl.jh
    field    gl    like jl.gl
    index main is primary crc dc rate credv debv.

def  new shared temp-table temp1
    field rate like joudoc.srate format "zzz9.99"
    field amt  like joudoc.dramt
    field jh as int
    field dc as char.

def  new shared temp-table temp2
    field rate  like joudoc.srate format "zzz9.99"
    field amt   like joudoc.dramt
    field jh as int
    field dc as char.

def new shared var v-amt as decimal.
def new shared var v-rate like  joudoc.srate format "zzzzzz9.99".
def new shared var v-rate1 like  joudoc.srate format "zzzzzz9.99".
def new shared var v-amtrate as decimal.

def  new shared stream   m-out.
def new shared var i as integer no-undo.

def new shared var v-gl1 like jl.gl  init 100100 no-undo.
def new shared var v-gl2 like jl.gl  init 100200 no-undo.
def new shared var v-gl3 like jl.gl  init 100300 no-undo.
def new shared var v-gl4 like jl.gl  init 100500 no-undo.

def new shared var v-dt as date no-undo.

{mainhead.i}
{functions-def.i}
 fdate = g-today.
 tdate = g-today.

def var s-ourbank as char.
find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
    display " There is no record OURBNK in bank.sysc file !!".
    pause.
    return.
end.
s-ourbank = trim(sysc.chval).

display
   fdate label " С "
   tdate label " по " with row 8 centered  side-labels frame opt title " Введите период: " .

   update fdate
          validate(fdate <= g-today,"Должно быть: начало <= сегодня")
          with frame opt.
   update tdate validate(tdate >= fdate and tdate <= g-today,
          "Должно быть: начало <= конец <= сегодня")
          with frame opt.

hide frame opt no-pause.

display "   Ждите...   "  with row 5 frame ww centered .


if s-ourbank ne 'TXB00' then do:
   do v-dt = fdate to tdate:
     hide message no-pause.
     message " Обработка " v-dt.
     for each jl where jl.jdt = v-dt and (jl.gl = v-gl1  or jl.gl = v-gl2 or jl.gl = v-gl3 or jl.gl = v-gl4) use-index jdt no-lock:
         if jl.crc = 1 or substring(jl.rem[1],1,5) <> "Обмен" then next.
         if jl.gl <> v-gl4 then do:
            if not ((jl.dam <> 0 and jl.ln = 1) or (jl.cam <> 0 and jl.ln = 4 )) then next.
         end.
         find joudoc where joudoc.jh = jl.jh and joudoc.who = jl.who and joudoc.whn = jl.jdt no-lock no-error.
         if avail joudoc then do.
            create temp.
            if jl.dam <> 0 then do.
               temp.dc    = "d".
               temp.debv  = /*joudoc.dramt*/ jl.dam.
               temp.crc   = jl.crc.
               temp.rate  = joudoc.brate.
               temp.jh = jl.jh.
               temp.gl = jl.gl.
             end.
             else do.
               temp.dc    = "c".
               temp.credv = /*joudoc.cramt*/ jl.cam.
               temp.crc = jl.crc.
               temp.rate = joudoc.srate.
               temp.jh = jl.jh.
               temp.gl = jl.gl.
             end.
         end.
     end.
   end.
end.
else run txbs("r-obval-txb").
output stream m-out to rpt.txt.
put stream m-out
    FirstLine( 1, 1 ) format "x(80)" skip(1)
    "            "
    "ОБЪЕМ КУПЛЕННОЙ И ПРОДАННОЙ ИНОСТРАННОЙ ВАЛЮТЫ  "  skip
    "                  "
    "за период с " string(fdate)  " по "  string(tdate) skip(1)
    FirstLine( 2, 1 ) format "x(80)" skip.
    put stream m-out  fill( "-", 80 ) format "x(80)"  skip.
    put stream m-out  " Валюта           Покупка          Продажа                Курс "   skip.
    put stream m-out space(48)                                        "Миним.   Максим.  Средневзв. " skip.
    put stream m-out  fill( "-", 80 ) format "x(80)"  skip(1).

for each temp break by temp.crc.

    if first-of(temp.crc) then do.
       find crc where crc.crc = temp.crc no-lock no-error.
       if avail crc then  put stream m-out " " crc.code " ".
       for each temp1.
           delete temp1.
       end.
       for each temp2.
           delete temp2.
       end.
    end.
    if temp.dc = "d" then do.
       create temp1.
       temp1.rate = temp.rate.
       temp1.amt = temp.debv.
       temp1.jh = temp.jh.
    end.
    else do.
       create temp2.
       temp2.rate = temp.rate.
       temp2.amt = temp.credv.
       temp2.jh = temp.jh.
    end.

    if last-of(temp.crc) then do.

        for each crchis where crc = temp.crc and rdt >= fdate and rdt <= tdate.
            accum crchis.rate[2] (minimum maximum).
            accum crchis.rate[3] (minimum maximum).
        end.

       v-amt = 0. v-rate = 0. v-rate1 = 0.  v-amtrate = 0.
       for each temp1.
          v-amt = v-amt + temp1.amt.
          v-amtrate = v-amtrate + (temp1.amt * temp1.rate).
          accum temp1.rate (minimum maximum).
       end.
       if (accum minimum crchis.rate[2]) <= (accum minimum temp1.rate) then v-rate  = (accum minimum crchis.rate[2]). else v-rate  = (accum minimum temp1.rate).
       if (accum maximum crchis.rate[2]) >= (accum maximum temp1.rate) then v-rate1 = (accum maximum crchis.rate[2]). else v-rate1 = (accum maximum temp1.rate).

       put stream m-out  "     " v-amt format "zzzz,zzz,zz9.99"
       space(18)
       v-rate
       v-rate1
       v-amtrate / v-amt skip.

       v-amt = 0. v-rate = 0. v-amtrate = 0.
       for each temp2.
          v-amt = v-amt + temp2.amt.
          v-amtrate = v-amtrate + (temp2.amt * temp2.rate).
          accum temp2.rate (minimum maximum).
       end.
       if (accum minimum crchis.rate[3]) <= (accum minimum temp2.rate) then v-rate  = (accum minimum crchis.rate[3]). else v-rate  = (accum minimum temp2.rate).
       if (accum maximum crchis.rate[3]) >= (accum maximum temp2.rate) then v-rate1 = (accum maximum crchis.rate[3]). else v-rate1 = (accum maximum temp2.rate).

       put stream m-out  space(28)  v-amt format "zzzz,zzz,zz9.99"
       v-rate
       v-rate1
       v-amtrate / v-amt skip.
      end.
end.
put stream m-out  fill( "-", 80 ) format "x(80)"  skip(1).

output stream m-out close.

{functions-end.i}

if not g-batch then do:
  pause 0.
  run menu-prt ("rpt.txt").
end.

hide frame ww no-pause.

