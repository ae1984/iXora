/* vcdocshis0.p
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
        18.08.2008 galina - перекомпеляция в связи с изменениями на форме vcdndocs.f
*/

/* vccthis.p Валютный контроль
   История документов

   08.11.2002 nadejda создан

*/

{vc.i}

def shared var s-vcdoctypes as char.
def shared var s-dnvid as char. 
def shared var s-contract like vccontrs.contract. 
def var v-contrnum as char.

{vc-vhis.i  
 &head = "vcdocs" 
 &headkey = "docs"
 &headhis = "vcdocshis"
 &start = " "
 &frame = "vcdndocs"
 &predisplay = "
      find vccontrs where vccontrs.contract = s-contract no-lock no-error.
      if avail vcdocs then run defvars. 
      else do: v-crckod = ''. v-dntypename = ''. end.
      if vccontrs.expimp = 'i' then v-contrnum = 'импорт, '. 
      else v-contrnum = 'экспорт, '. 
      v-contrnum = v-contrnum + trim(vccontrs.ctnum) + ' от ' + string(vccontrs.ctdate, '99/99/9999'). 
      "
 &header = "ДОКУМЕНТА" 
 &displcif = "true"
 &display = "
      vcdocs.dntype v-dntypename 
      vcdocs.dnnum vcdocs.dndate vcdocs.sumpercent vcdocs.pcrc v-crckod vcdocs.sum 
      vcdocs.cursdoc-con vcdocs.sum / vcdocs.cursdoc-con @ v-sumdoccon 
      vcdocs.payret when (index('p', s-dnvid) > 0 or vcdocs.dntype = '17') 
      vcdocs.info[1] 
      vcdocs.knp when index('g', s-dnvid) = 0 
      vcdocs.kod14 when index('p', s-dnvid) > 0 
      vcdocs.rdt vcdocs.rwho vcdocs.cdt vcdocs.cwho " 
}

procedure defvars.
  find ncrc where ncrc.crc = vcdocs.pcrc no-lock no-error.
  if avail ncrc then do:
  v-crckod = ncrc.code. end.
  else do: v-crckod = ''. end.
  find codfr where codfr.codfr = "vcdoc" and codfr.code = vcdocs.dntype no-lock no-error. 
  if avail codfr then v-dntypename = codfr.name[2]. else v-dntypename = "". 
end.

