/* lonres+.p
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

/*-----------------------------------------------------------------------------
  #3.Programma nodroЅina fail– lon akumulёto aprё±in–to procentu un procentu
     uzkr–jumu pieskaitЁЅanu,izpildot transakciju galvenaj– ·urn–l–,k–
     arЁ izveido atbilstoЅo ierakstu fail– lonres kontiem ar subledgeru
     LON.LЁmeni Ѕeit nekontrolё,t–pёc var b­t jebkurЅ

     Izmai‡as:
       - ja apmaks– procentus par pag–juЅo gadu, to piefiksё
         kas agr–k netika darЁts (transakcijas ar aprё±in–tajiem % nav, bet
         fail– lonres to atzЁmё, ja ir pag–juЅaj– gad– bilancё ieskaitЁti
         aprё±in–tie %)
       - atcelta iepriekЅёj– izmai‡a

  #4.Parametri p-jh - transakcijas numurs
               p-ln - faila jl formёjam–s rindas numurs
     Shared mainЁgais g-today
     Faili jl
           gl
           lon
  #5.Faili lon
           lonres
  #7.Programmu izsauc lonres+1.p
------------------------------------------------------------------------------*/
define input parameter p-jh  like jl.jh.
define input parameter p-ln  like jl.ln.

define shared variable g-today as date.

define       variable v-gl701  like jl.gl.
define       variable v-acc    like jl.acc.
define       variable v-tim    like lonres.tim.
define new shared variable s-longl as integer extent 20.
define       variable ok as logical.

v-tim = time.
find jh where jh.jh = p-jh no-lock.
find jl where jl.jh = p-jh and jl.ln = p-ln no-lock no-error.
find lon where lon.lon = jl.acc exclusive-lock.
run f-longl(lon.gl,"gl701",output ok).
if not ok
then do:
     bell.
     message lon.lon " - lonres+: longl не определен счет".
     pause.
     return.
end.
v-gl701 = s-longl[1].

v-acc = "LRES" + string(year(g-today),"9999") +
        string(month(g-today),"99").
create lonres.
lonres.lon = lon.lon.
lonres.ln = jl.ln.
lonres.dlt = no.
lonres.tim = v-tim.
lonres.mn = v-acc.
lonres.jh = jh.jh.
lonres.who = jl.who.
lonres.whn = jh.jdt.
lonres.dc = jl.dc.
lonres.crc = lon.crc.
lonres.crc1 = jl.crc.
lonres.gl1 = v-gl701.
lonres.gl = jl.gl.
if lonres.dc = "C"
then lonres.amt = jl.cam.
else lonres.amt = jl.dam.
find gl where gl.gl = lonres.gl no-lock.
lon.dam[gl.level] = lon.dam[gl.level] + jl.dam.
lon.cam[gl.level] = lon.cam[gl.level] + jl.cam.
if gl.level = 3
then do:
     lon.prnyrs = lonres.crc1.
     find last lonhar where lonhar.lon = lon.lon and lonhar.fdt <= g-today 
          exclusive-lock no-error.
     if available lonhar
     then do:
          lonhar.rez-log[1] = yes.
          lonhar.rez-char[1] = lonhar.rez-char[1] + string(jl.jh) + "&".
     end.
end.
