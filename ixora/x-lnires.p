/* x-lnires.p
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
  #1.4-1-5
  #3.Programma:
     - formё transakciju ar bilancё ierakst–maj–m aprё±in–to procentu
       un uzkr–jumu summ–m
     - izveido atbilstoЅos ierakstus fail– lonres par katra kredЁta summu

       1.izmai‡a - ja uzkr–jums atzЁmёts k– pёdёjais (lauks
         loncon.rez-int[4] = 1), tad, ja uzkr–jums patieЅ–m tiek izdarЁts,
         lauk– lon.team tiek pielikta pazЁme "!!!".

  #4.Shared mainЁgie s-grp
                     s-crc
                     s-apr
                     s-uzk
                     s-gl701
                     s-gl471
                     s-gl240
                     s-gl808
     Faili jh
           jl
           gl
           lon
           loncon
  #5.Faili jl
           lonres
------------------------------------------------------------------------------*/
define shared variable s-mn    like lonres.mn.
define shared variable s-grp   like lon.grp.
define shared variable s-crc   like lon.crc.
define shared variable s-apr   like lon.opnamt.
define shared variable s-uzk   like lon.opnamt.
define shared variable s-gl701 like gl.gl.
define shared variable s-gl240 like gl.gl.
define shared variable s-gl471 like gl.gl.
define shared variable s-gl808 like gl.gl.

define variable v-acc   as character.
define variable v-apr   like lon.opnamt.
define variable v-uzk   like lon.opnamt.
define variable v-aprk  like lon.opnamt.
define variable v-uzkk  like lon.opnamt.
define variable v-frst1 as logical.
define variable v-frst2 as logical.
define variable v-tim   like lonres.tim.

def new shared var s-consol like jh.consol initial false.
def new shared var s-aah  as int.
def new shared var s-line as int.
def new shared var s-force as log initial false.
def new shared var s-jh like jh.jh.
def new shared var xjh like jh.jh.
def var vrem as cha format "x(55)".
def var vamt like jl.dam.
def var vln as int.
def new shared var vtot as dec format "zz,zzz,zz9.99-".


v-acc = s-mn.
v-aprk = s-apr.
v-uzkk = s-uzk.
v-tim = time.

if v-aprk > 0 or v-uzkk > 0
then do:

     run x-jhnew.
     find jh where jh.jh = s-jh.
     v-frst1 = yes.
     v-frst2 = yes.
     vln = 0.
     for each loncon where loncon.rez-char[3] = s-mn and
         loncon.rez-int[2] = s-crc and loncon.rez-int[3] = s-grp and
         (loncon.rez-dec[2] > 0 or loncon.rez-dec[4] > 0) no-lock transaction:
         find lon where lon.lon = loncon.lon exclusive-lock.
         v-apr = loncon.rez-dec[1].
         v-uzk = loncon.rez-dec[3].
         if v-apr <> 0
         then do:
              find gl where gl.gl = s-gl701 no-lock.
              lon.dam[gl.level] = lon.dam[gl.level] + v-apr.
              vln = vln + 1.
              create lonres.
              lonres.lon = lon.lon.
              lonres.ln  = vln.
              lonres.dlt = no.
              if v-frst1
              then do:
                   lonres.dlt = yes.
                   v-frst1 = no.
              end.
              lonres.tim = v-tim.
              lonres.mn  = s-mn.
              lonres.jh  = jh.jh.
              lonres.dc  = "D".
              lonres.gl1 = s-gl701.
              lonres.gl = s-gl240.
              lonres.amt = v-apr.
              lonres.who = jh.who.
              lonres.whn = jh.jdt.
         end.
         if v-uzk <> 0
         then do:
              find gl where gl.gl = s-gl471 no-lock.
              lon.cam[gl.level] = lon.cam[gl.level] + v-uzk.
              if loncon.rez-int[4] = 1
              then lon.team = "!!!".
              else lon.team = "".
              vln = vln + 1.
              create lonres.
              lonres.lon = lon.lon.
              lonres.ln  = vln.
              lonres.dlt = no.
              if v-frst1
              then do:
                   lonres.dlt = yes.
                   v-frst1 = no.
              end.
              lonres.tim = v-tim.
              lonres.mn  = s-mn.
              lonres.jh  = jh.jh.
              lonres.dc  = "C".
              lonres.gl1 = s-gl701.
              lonres.gl = s-gl471.
              lonres.amt = v-uzk.
              lonres.who = jh.who.
              lonres.whn = jh.jdt.
         end.
     end.
     do transaction :
        {mainhead.i}
        jh.cif = "".
        jh.crc = s-crc.
        jh.party = "lonres".

        if not v-frst1
        then do:
             find first lonres where lonres.jh = jh.jh and lonres.dlt
                  exclusive-lock no-error.
             if available lonres
             then lonres.dlt = no.
        end.
        /*
        if not v-frst2
        then do:
             find first lonres where lonres.jh = jh.jh and
                  lonres.gl = s-gl471 and lonres.dlt exclusive-lock no-error.
             if available lonres
             then lonres.dlt = no.
        end.
        */
        vln = 1.
        if v-aprk > 0
        then do:  /* aprё±in–tie % */
             create jl.
             jl.jh = jh.jh.
             jl.crc = jh.crc.
             jl.ln = vln.
             jl.who = jh.who.
             jl.jdt = jh.jdt.
             jl.whn = jh.whn.
             find gl where gl.gl = s-gl701 no-lock.
             jl.gl = gl.gl.
             jl.acc = "".
             jl.dc = "C".
             jl.cam = v-aprk.
             vamt = jl.cam.
             jl.rem[2] = "REF:" + v-acc  + "-рассчитанные %".
             vrem = jl.rem[2].
             vln = vln + 1.
             create jl.
             jl.jh = jh.jh.
             jl.ln = vln.
             jl.crc = jh.crc.
             jl.who = jh.who.
             jl.jdt = jh.jdt.
             jl.whn = jh.whn.
             jl.gl =  s-gl240.
             jl.acc = v-acc.
             jl.dc = "D".
             jl.dam = v-aprk.
             find gl where gl.gl = jl.gl no-lock.
             vln = vln + 1.
        end.
        if v-uzkk > 0
        then do: /* uzkr–jums */
             create jl.
             jl.jh = jh.jh.
             jl.crc = jh.crc.
             jl.ln = vln.
             jl.who = jh.who.
             jl.jdt = jh.jdt.
             jl.whn = jh.whn.
             jl.gl = s-gl471.
             find gl where gl.gl = jl.gl no-lock.
             jl.acc = v-acc.
             jl.dc = "C".
             jl.cam = v-uzkk.
             vamt = vamt + jl.cam.
             jl.rem[2] = v-acc + "/:" +  "*" + "- % накоплен.".
             jl.rem[3] = vrem.
             vln = vln + 1.
             create jl.
             jl.jh = jh.jh.
             jl.ln = vln.
             jl.crc = jh.crc.
             jl.who = jh.who.
             jl.jdt = jh.jdt.
             jl.whn = jh.whn.
             jl.gl =  s-gl808.
             jl.acc = "".
             jl.dc = "D".
             jl.dam = v-uzkk.
             find gl where gl.gl = jl.gl no-lock.
             vln = vln + 1.
        end.

/* */

        find first jl where jl.jh = s-jh no-error.
        if available jl
        then do:
             {mesg.i 0933} s-jh.
             s-jh = jh.jh.
             run x-jlvou.
             jh.sts = 5.
             for each jl of jh:
                 jl.sts = 5.
             end.
        end.

        pause 0.
     end.
     run lonres--.
end.
