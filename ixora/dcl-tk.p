/* dcl-tk.p
 * MODULE
        Закрытие ОД 
 * DESCRIPTION
        Создание таблицы транзакций по ticket
 * RUN
        вызывается из dayclose.p
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        01.08.2003 nadejda - оптимизация циклов для использования индексов
        17.03.2004 nataly  - добавлена валюта + счет ARP в EUR (076643)
        29.07.2005 nataly  - добавлена проверка на ticket   - если есть ticket с проводокой, то он не дублируется 
*/

def buffer bgl for gl.
def buffer bjl for jl.

def var v-gloda like gl.gl init 187010.
def var v-arpoda as char init "000076106,000076643".

def var v-gl like gl.gl.
def var v-arp as char.
def var v-des like gl.des.
def var v-kom as decimal.
def var n as integer.

def var i as date.

def var s-jh as integer.

{global.i}

def temp-table t-arp 
  field arp like arp.arp
  field gl like gl.gl
  field des as char
  index main is primary unique gl arp.

for each arp no-lock where arp.gl = v-gloda:
  create t-arp.
  assign t-arp.arp = arp.arp
         t-arp.gl = arp.gl
         t-arp.des = arp.des.

end.

do n = 1 to num-entries (v-arpoda):
  v-arp = entry(n, v-arpoda).

  find t-arp where t-arp.arp = v-arp no-error.
  if not avail t-arp then do:
    find arp where arp.arp = v-arp no-lock no-error.
    if avail arp then do:
      create t-arp.
      t-arp.arp = arp.arp.

      find trxlevgl where trxlevgl.gl = arp.gl and trxlevgl.subled = "arp" and trxlevgl.lev = 7 no-lock no-error.
      if available trxlevgl then t-arp.gl = trxlevgl.glr.
    end.
  end.
end.

for each t-arp :
  for each jl where jl.acc = t-arp.arp and jl.jdt = g-today and jl.dc = "d" no-lock use-index accdcjdt:

    if s-jh <> jl.jh then  do:
      /* учитываем комиссию за транзакцию */
      find bjl where bjl.jh = jl.jh and bjl.acc = jl.acc and bjl.dc = "d" and bjl.ln <> jl.ln use-index jhln no-lock no-error.
      if available bjl then v-kom = bjl.dam. 
                       else v-kom = 0.

    find ticket where ticket.jh1 = jl.jh and ticket.arp = t-arp.arp no-lock no-error.
    if avail ticket then next.
      create ticket. 
      assign ticket.jh1 = jl.jh 
             ticket.arp = t-arp.arp
             ticket.dt1 = jl.jdt
             ticket.gl = t-arp.gl
             ticket.crc = jl.crc
             ticket.amt[1] = jl.dam + v-kom.


      if t-arp.des = "" then ticket.des = jl.rem[2].
                        else ticket.des = t-arp.des.
      
      s-jh = jl.jh.
    end. /*s-jh <> jl.jh*/

    v-kom  = 0.
  end.  /* for each jl */
end.


/* 01.08.2003 nadejda переделала цикл по другому, см.выше

for each arp no-lock where arp.gl = 187010 or arp.arp = "000076106"  
    break by arp.gl by arp.crc:


/ * Соединяем главную книгу с ARP * /
   if arp.arp <> "000076106" then 
    find gl where gl.gl eq arp.gl no-lock.
   else do:
     find trxlevgl where trxlevgl.gl = arp.gl and trxlevgl.subled = "arp"
        and trxlevgl.lev = 7 no-lock no-error.
     if available trxlevgl 
      then  do: 
       find bgl where bgl.gl = trxlevgl.glr no-lock no-error.
       v-gl = bgl.gl. v-des = bgl.des.
      end.
   end.

  for each jl   no-lock where jl.acc eq arp.arp   and 
     (  jl.gl = 187010 or jl.gl = v-gl)
         and jl.jdt eq g-today and jl.dc = "d" 
          use-index acc:  

   if s-jh <> jl.jh then  do:
    / * учитываем комиссию за транзакцию * /
    find bjl where  bjl.acc = jl.acc and bjl.jh = jl.jh and bjl.dc = "d" 
        and bjl.ln <> jl.ln use-index acc  no-lock no-error.
    if available bjl then v-kom = bjl.dam. 
      else v-kom = 0.

    create ticket. 
      ticket.jh1 =  jl.jh . ticket.arp =  arp.arp. 
      ticket.dt1 = jl.jdt .
    if arp.gl = 187010  then do:
      ticket.gl = arp.gl.  ticket.des = arp.des.
    end.
    else  do: 
      ticket.gl = v-gl. ticket.des = jl.rem[2].
    end.
     ticket.amt[1] = jl.dam + v-kom . 
     s-jh = jl.jh.
   end. / *s-jh <> jl.jh* /

     v-kom  = 0.
  end. / *for each jl* /
end.  / *for each arp* /
*/
