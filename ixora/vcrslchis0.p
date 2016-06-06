/* vcrslchis0.p
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

/* vccthis.p Валютный контроль
   История рег.св-в/лицензий

   08.11.2002 nadejda создан

*/

{vc.i}

def shared var s-contract like vccontrs.contract. 
def var v-contrnum as char.

{vc-vhis.i  
 &head = "vcrslc" 
 &headkey = "rslc"
 &headhis = "vcrslchis"
 &frame = "vcdnrslc"
 &predisplay = "
      find vccontrs where vccontrs.contract = s-contract no-lock no-error.
      if avail vcrslc then run defvars. 
      else do: v-dntypename = ''. end.
      if vccontrs.expimp = 'i' then v-contrnum = 'импорт, '. 
      else v-contrnum = 'экспорт, '. 
      v-contrnum = v-contrnum + trim(vccontrs.ctnum) + ' от ' + string(vccontrs.ctdate, '99/99/9999'). 
      "
 &header = "РЕГ.СВ-ВА/ЛИЦЕНЗИИ" 
 &displcif = "true"
 &display = "vcrslc.dntype v-dntypename 
             vcrslc.dnnum vcrslc.dndate 
             vcrslc.lastdate vcrslc.sum
             vcrslc.rdt vcrslc.rwho vcrslc.cdt vcrslc.cwho " 
}

procedure defvars.
  find codfr where codfr.codfr = "vcdoc" and codfr.code = vcrslc.dntype no-lock no-error. 
  if avail codfr then v-dntypename = codfr.name[2]. else v-dntypename = "". 
end.

