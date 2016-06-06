/* s-fakst.p
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
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

define shared variable g-today as date. 
define shared variable s-lon like lon.lon.
define shared variable ppay like lon.opnamt.
define shared variable ipay like lon.opnamt.
define shared variable algpay as decimal.
define shared variable apay as decimal.
define shared variable a-gl like gl.gl.

define new shared variable s-longl as integer extent 20.
define variable ok as logical.
define variable var as character.
define variable i   as integer.
define variable j   as integer.
define variable min-lon like lon.lon.
define variable max-lon like lon.lon.
define variable amt1 as decimal.
define variable amt2 as decimal.
define variable amt21 as decimal.
define variable amt3 as decimal.
define variable amt4 as decimal.
define variable amt34 as decimal.
define variable amt5 as decimal.
define shared variable rc as integer.

define buffer fagra1 for fagra.

form fagra.nr    format "x(10)"          label "Nr документа...."
     fagra.falon format "x(13)"          label "Счет............"
     facif.name  format "x(50)"          label "Покупатель......"
     amt1        format ">>>,>>>,>>9.99" label "Долг............"
     amt2        format ">>>,>>>,>>9.99" label "Погашение кредит"
     validate(amt2 <= amt21,"Сумма погашения превышает выданную!")
     amt4        format ">>>,>>>,>>9.99" label "Доход банка....."
     validate(amt21 + amt4 <= amt1,
                 "Доход !")
     amt5        format ">>>,>>>,>>9.99" label "Оплата труда...."
     validate(amt21 + amt4 + amt5 <= amt1,
                 "Доход + оплата труда !")
     loncon.konts format "x(10)"         label "Счет клиента...."
     amt3        format ">>>,>>>,>>9.99" label "Перечисление...."
     validate(amt21 + amt3 + amt4 + amt5 <= amt1,
                 "доход + оплата труда + перечисление !")
     ok                                  label "Оформлять ?....."
     with overlay side-label 1 columns row 9 column 10 frame fagra.

   find lon where lon.lon = s-lon no-lock.
   find loncon where loncon.lon = s-lon no-lock.
   run f-longl(lon.gl,"sa%gl,lon%gl,gl-atalg",output ok).
   rc = 0.
   if not ok
   then do:
        bell.
        message lon.lon " - s-lonstj:" 
                "longl не определен счет".
        rc = 1.
        pause.
        return.
   end.
   if lon.gua = "FK"
   then do:
        find aaa where aaa.aaa = loncon.konts no-lock no-error.
        if not available aaa
        then do:
             /* message "Neeksistё norё±inu konts".
             pause. */
             rc = 1.
             /* return. */
        end.
        if rc = 0
        then a-gl = aaa.gl.
        else do: 
             a-gl = 0.
             rc = 0.
        end.
{s-edit1.i
 &rz = "1"  
 &var = "var"  
 &file = "fagra"  
 &index = "falon"
 &where = "fagra.lon = lon.lon and fagra.pf = 'P' and fagra.gl = lon.gl and
  fagra.dc = 'C' "
 &i = "i"  
 &j = "j"  
 &n = "1"  
 &key = "nr"  
 &min-key = "min-lon"  
 &max-key = "max-lon"  
 &frame = "fagra"
 &postfind = " ok = no. find falon where falon.falon = fagra.falon no-lock. find
  facif where facif.facif = falon.facif no-lock. amt1 = fagra.amt. for each      fagra1 where fagra1.falon = falon.falon and fagra1.pf = 'F' and fagra1.gl =    lon.gl and fagra1.nr = fagra.nr and fagra1.dc = 'C' and fagra1.jh > 0 
  no-lock: amt1 = amt1 - fagra1.amt. end. amt21 =  0. for each fagra1 where 
  fagra1.falon = falon.falon and fagra1.pf = 'F' and fagra1.nr = fagra.nr and      fagra1.gl = lon.gl and fagra1.gl1 = lon.gl and fagra1.jh > 0 no-lock: if         fagra1.dc = 'C' then amt21 = amt21 - fagra1.amt. else amt21 = amt21 + 
  fagra1.amt. end. find first fagra1 where fagra1.falon = falon.falon and         fagra1.pf = 'F' and fagra1.gl = lon.gl and fagra1.gl1 = lon.gl and fagra1.nr =   fagra.nr and fagra1.dc = 'C' and fagra1.jh = 0 no-lock no-error. if       available fagra1 then do: ok = yes. amt2 = fagra1.amt. end. else amt2 =   amt21. find first fagra1 where fagra1.falon = falon.falon and fagra1.pf = 'F'   and fagra1.gl = lon.gl and fagra1.gl1 = s-longl[2] and fagra1.nr = fagra.nr   and fagra1.dc = 'C' and fagra1.jh = 0 no-lock no-error. if available fagra1   then do: ok = yes. amt4 = fagra1.amt. end. else do: find first fagra1 where   fagra1.falon = falon.falon and fagra1.pf = 'F' and fagra1.gl = lon.gl and   fagra1.nr = fagra.nr and fagra1.dc = 'D' and fagra1.jh > 0 no-lock no-error.   if available fagra1 then amt4 = round(lon.prem   / 100 * amt2 * (g-today -   fagra1.whn + 1) / lon.basedy,2). else amt4 = round(lon.prem / 100 * amt2,2).   end. find first fagra1 where fagra1.falon = falon.falon and fagra1.pf = 'F'    and fagra1.gl = lon.gl and fagra1.gl1 = s-longl[3] and fagra1.nr = fagra.nr     and fagra1.dc = 'C' and fagra1.jh = 0 no-lock no-error. if available fagra1     then do: ok = yes. amt5 = fagra1.amt. end. else amt5 = 0. 
  if a-gl > 0 then do: find first fagra1 where fagra1.falon = falon.falon   and fagra1.pf = 'F' and fagra1.gl = lon.gl and fagra1.gl1 = aaa.gl and   fagra1.nr = fagra.nr and fagra1.dc = 'C' and fagra1.jh = 0 no-lock no-error.   if available fagra1 then do: ok = yes. amt3 = fagra1.amt. end. else amt3 =   amt1 - amt2 - amt4 - amt5. end. else amt3 = 0. "
 &display = "fagra.nr fagra.falon facif.name amt1 amt2 amt4 amt5 loncon.konts     amt3 ok"
 &preupdate = "update amt2 with frame fagra. if frame fagra amt2 entered
  then do: find first fagra1 where fagra1.falon = falon.falon and fagra1.pf =     'F' and fagra1.gl = lon.gl and fagra1.nr = fagra.nr and fagra1.dc = 'D' and      fagra1.jh > 0 no-lock no-error. if available fagra1 then amt4 = round(lon.prem   / 100 * amt2 * (g-today - fagra1.whn + 1) / lon.basedy,2). display amt4 with     frame fagra. end. update amt4 with frame fagra. if frame fagra amt4 entered     and a-gl > 0 then do: amt3 = amt1 - amt21 - amt4 - amt5. display amt3 with     frame fagra. end. update amt5 with frame fagra. if frame fagra amt5 entered     and a-gl > 0 then do: amt3 = amt1 - amt21 - amt4 - amt5. display amt3 with       frame fagra. end. if a-gl  > 0 then update amt3 with frame fagra. "
 &update = "ok"
 &postupdate = "run p-updt. "
 &precreate = " "
 &postcreate = " "
 &predelete = " "
 &postdelete = " "
 &end  = " "}.
        ppay = 0. 
        apay = 0. 
        ipay = 0. 
        algpay = 0.
        for each fagra1 where fagra1.lon = lon.lon and fagra1.pf = 'F' and
            fagra1.gl = lon.gl and fagra1.jh = 0 and fagra1.dc = 'C' no-lock:
            if fagra1.gl1 = lon.gl 
            then ppay = ppay + fagra1.amt.
            else if a-gl > 0 and fagra1.gl1 = aaa.gl 
                 then apay = apay + fagra1.amt. 
                 else if fagra1.gl1 = s-longl[2] 
                      then ipay = ipay + fagra1.amt. 
                      else if fagra1.gl1 = s-longl[3]
                      then algpay = algpay + fagra1.amt.
        end.  
   end.   

procedure p-updt:

 find first fagra1 where fagra1.falon = falon.falon and fagra1.pf = 'F' and
      fagra1.gl = lon.gl and fagra1.gl1 = lon.gl and fagra1.nr = fagra.nr and        fagra1.dc = 'C' and fagra1.jh = 0 exclusive-lock no-error.
 if available fagra1 
 then do: 
      if ok 
      then fagra1.amt = amt2. 
      else delete fagra1.
 end. 
 else if ok 
 then do: 
      create fagra1. 
      fagra1.lon = lon.lon. 
      fagra1.falon = falon.falon. 
      fagra1.nr = fagra.nr. 
      fagra1.dt = g-today. 
      fagra1.pf = 'F'. 
      fagra1.dc = 'C'. 
      fagra1.gl = lon.gl. 
      fagra1.gl1 = lon.gl. 
      fagra1.jh = 0. 
      fagra1.amt = amt2. 
      fagra1.acc = lon.lon. 
      fagra1.who = userid('bank'). 
      fagra1.whn = g-today. 
 end. 
 find first fagra1 where fagra1.falon = falon.falon and fagra1.pf = 'F' and
      fagra1.gl = lon.gl and fagra1.gl1 = s-longl[2] and fagra1.nr = fagra.nr       and fagra1.dc = 'C' and fagra1.jh = 0 exclusive-lock no-error. 
 if available fagra1 
 then do: 
      if ok 
      then fagra1.amt = amt4. 
      else delete fagra1. 
 end. 
 else if ok 
 then do: 
      create fagra1. 
      fagra1.lon = lon.lon. 
      fagra1.falon = falon.falon. 
      fagra1.nr = fagra.nr. 
      fagra1.dt = g-today. 
      fagra1.pf = 'F'. 
      fagra1.dc = 'C'. 
      fagra1.gl = lon.gl. 
      fagra1.gl1 = s-longl[2]. 
      fagra1.jh = 0. 
      fagra1.amt = amt4. 
      fagra1.acc = lon.lon. 
      fagra1.who = userid('bank'). 
      fagra1.whn = g-today. 
 end. 
 if a-gl > 0 
 then do: 
      find first fagra1 where fagra1.falon = falon.falon and fagra1.pf = 'F'
           and fagra1.gl = lon.gl and fagra1.gl1 = aaa.gl and fagra1.nr =            fagra.nr and fagra1.dc = 'C' and fagra1.jh = 0 exclusive-lock            no-error. 
      if available fagra1 
      then do: 
           if ok 
           then fagra1.amt = amt3. 
           else delete fagra1. 
      end. 
      else if ok 
      then do: 
           create fagra1. 
           fagra1.lon = lon.lon. 
           fagra1.falon = falon.falon. 
           fagra1.nr = fagra.nr. 
           fagra1.dt = g-today. 
           fagra1.pf = 'F'. 
           fagra1.dc = 'C'. 
           fagra1.gl = lon.gl. 
           fagra1.gl1 = aaa.gl. 
           fagra1.jh = 0. 
           fagra1.amt = amt3. 
           fagra1.acc = aaa.aaa. 
           fagra1.who = userid('bank'). 
           fagra1.whn = g-today. 
      end.
 end. 
 if s-longl[3] > 0 
 then do: 
      find first fagra1 where fagra1.falon = falon.falon and fagra1.pf = 'F' 
           and fagra1.gl = lon.gl and fagra1.gl1 = s-longl[3] and fagra1.nr =             fagra.nr and fagra1.dc = 'C' and fagra1.jh = 0 exclusive-lock                   no-error. 
      if available fagra1 
      then do: 
           if ok 
           then fagra1.amt = amt5. 
           else delete fagra1. 
      end. 
      else if ok 
      then do: 
           create fagra1. 
           fagra1.lon = lon.lon. 
           fagra1.falon = falon.falon. 
           fagra1.nr = fagra.nr. 
           fagra1.dt = g-today. 
           fagra1.pf = 'F'. 
           fagra1.dc = 'C'. 
           fagra1.gl = lon.gl. 
           fagra1.gl1 = s-longl[3]. 
           fagra1.jh = 0. 
           fagra1.amt = amt5. 
           fagra1.acc = " ". 
           fagra1.who = userid('bank'). 
           fagra1.whn = g-today. 
      end.
 end. 

 end procedure.
