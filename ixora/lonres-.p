/* lonres-.p
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
        14/02/2007 madiyar - поле lon.sts используем под статус кредита (погашен/не погашен), соотв. изменения
*/

/*-----------------------------------------------------------------------------
  #3.Programma nodroЅina fail– lon akumulёto aprё±in–to procentu un procentu
     uzkr–jumu at‡emЅanu,izpildot transakciju galvenaj– ·urn–l–,k–
     arЁ dzёЅ atbilstoЅos ierakstus fail– lonres kontiem ar subledgeru
     LON un lЁmeni 4 vai 5 atseviЅ±iem kredЁtiem vai atzЁmё vienu ierakstu
     k– dzёЅamu,ja transakcija izpildЁta ar kredЁtu grupu

     1.izmai‡a - ‡em vёr–, vai transakcija attiecas uz Ѕo vai pag–juЅo gadu:
       atbilstoЅi kori¦ё lon.cam[4],lon.dam[4] vai lon.ycam[4],lon.ydam[4]
     2.izmai‡a - no‡em pazЁmi lon.team = "!!!", kas nozЁmё 100 % uzkr–jumu, ja
       dzёЅ uzkr–juma kredЁtu
     3.izmai‡a - pieliek pazЁmi lon.team = "!!!", ja dzёЅ uzkr–juma debetu un
       pirms tam ir bijusi pazЁme lon.team = "!!"
     4.izmai‡a - atceµ 1.izmai‡u
     5.izmai‡a - dzёЅ statusa fiks–ciju, kas izdarЁta pie uzkr–Ѕanas
     6.izmai‡a - lon.team = "!!!" taisa par lon.team = "!!", ja dzёЅ uzkr–juma
       kredЁtu (sal. ar 2.izm.)

  #4.Parametri p-jh  - transakcijas numurs
               p-ln  - transakcijas rindas numurs
     Faili gl
           lon
           lonres
  #5.Faili lon
           lonres
  #6.
  #7.Programmu izsauc lonres-1.p
------------------------------------------------------------------------------*/
define input parameter p-jh  like jl.jh.
define input parameter p-ln  like jl.ln.
define shared variable g-today as date.
define variable c-jh as character.
define variable r    as character.
define variable i as integer.
define variable v-gl like gl.gl.
define buffer jl1 for jl.
define new shared variable s-longl as integer extent 20.
define variable ok as logical.

find jl where jl.jh = p-jh and jl.ln = p-ln no-lock.

if jl.acc begins "LRES" 
then do:
     find first lonres where lonres.jh = p-jh and lonres.dlt
          no-lock no-error.
     if available lonres
     then.
     else do:
          find first lonres where lonres.jh = p-jh exclusive-lock no-error.
          if available lonres
          then lonres.dlt = yes.
     end.
end.
else do:
     find lonres where lonres.jh = p-jh and lonres.ln = p-ln no-error.
     if available lonres 
     then do:
          find lon where lon.lon = lonres.lon exclusive-lock.
          find gl where gl.gl = lonres.gl no-lock. 
          if gl.level < 5
          then do:
               if lonres.dc = "C"
               then lon.cam[gl.level] = lon.cam[gl.level] - lonres.amt.
               else lon.dam[gl.level] = lon.dam[gl.level] - lonres.amt.
          end.
          else do:
               if lonres.dc = "C"
               then do:
                    lon.cam[gl.level] = lon.cam[gl.level] - lonres.amt.
                    if lon.team = "!!!"
                    then do:
                        find last lonhar use-index lonln where 
                             lonhar.lon = lon.lon and
                             lonhar.rez-log[1] no-lock no-error.
                        if not available lonhar
                        then lon.team = "!!".
                        else if lonhar.lonstat < 3
                        then lon.team = "!!".
                    end.
               end.
               else do:
                    lon.dam[gl.level] = lon.dam[gl.level] - lonres.amt.
                    if lon.team = "!!"
                    then lon.team = "!!!".
               end.
          end.
          delete lonres. 
          if gl.level = 3
          then do:
               if jl.dc = "D" /* and lon.sts = 8 */
               then do:
                    run f-longl(lon.gl,"gl310250",output ok).
                    if not ok
                    then do:
                         bell.
                         message lon.lon " - lonres-: longl не определен счет".
                         pause.
                         return.
                    end.
                    v-gl = s-longl[1].
                    find first jl1 where jl1.jh = p-jh and
                         jl1.acc = lon.lon and jl1.gl = v-gl no-lock no-error.
                    if available jl1
                    then lon.cam[2] = lon.cam[2] - jl1.dam.
                    /* lon.sts = 2. */
               end.
               c-jh = string(p-jh).
               find first lonhar where lonhar.lon = lon.lon and 
                    index(lonhar.rez-char[1],c-jh) > 0 no-error.
               if available lonhar
               then do:
                    r = lonhar.rez-char[1].
                    i = index(r,c-jh).
                    if i = 1
                    then do:
                         if i + length(c-jh) = length(r)
                         then lonhar.rez-char[1] = "".
                         else lonhar.rez-char[1] = 
                                     substring(r,i + length(c-jh) + 1).
                    end.
                    else do:
                         if i + length(c-jh) = length(r)
                         then lonhar.rez-char[1] = substring(r,1,i - 1).
                         else lonhar.rez-char[1] = substring(r,1,i - 1) +
                                     substring(r,i + length(c-jh) + 1).
                    end.
                    if trim(lonhar.rez-char[1]) = ""
                    then lonhar.rez-log[1] = no.
               end.
               if lon.dam[4] - lon.cam[4] > lon.cam[5] - lon.dam[5] or
                  lon.cam[5] = 0
               then do:
                    find last lonhar use-index lonln where 
                         lonhar.lon = lon.lon and
                         lonhar.rez-log[1] no-lock no-error.
                    if not available lonhar
                    then lon.team = "".
                    else if lonhar.lonstat < 3
                    then lon.team = "".
               end.
          end.      
     end.
end.
