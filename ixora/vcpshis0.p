/* vcpshis0.p
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
 * BASES
        BANK COMM
 * CHANGES
*/      /* vccthis.p Валютный контроль
        История пасп.сделок/доплистов

        08.11.2002 nadejda - создан
        25.03.2008 galina  - изменен формат вывода номера паспорта сделки/доп.листа
        12/10/2010 aigul   - перекомпиляция из за vcpnds.p
        29/11/2010 aigul   - замена vcps.dnnote[5] на v-note
        02.07.2012 damir   - добавил s-check.
        */
{vc.i}

def shared var s-contract like vccontrs.contract.
def shared var v-chk as logic initial no.
def var v-contrnum as char.
def var v-dnnum as char.
/*aigul*/
def var v-note as char format "x(50)".
def var v-note1 as char format "x(50)".
def var v-note2 as char format "x(50)".
def var v-note3 as char format "x(50)".
def var v-note4 as char format "x(50)".
def var v-note5 as char format "x(50)".
def var s-check as char.
/**/
{vc-vhis.i
 &head = "vcps"
 &headkey = "ps"
 &headhis = "vcpshis"
 &frame = "vcdnps"
 &predisplay = "
      find vccontrs where vccontrs.contract = s-contract no-lock no-error.
      if avail vcps then do:
         if vcps.dntype = '01' then v-dnnum = vcps.dnnum + string(vcps.num).
                else v-dnnum = vcps.dnnum.
         run defvars.
      end.
      else do: v-nbcrckod = ''. v-dntypename = ''. v-rslctype = ''. v-dnnum = ''. end.
      if vccontrs.expimp = 'i' then v-contrnum = 'импорт, '.
      else v-contrnum = 'экспорт, '.
      v-contrnum = v-contrnum + trim(vccontrs.ctnum) + ' от ' + string(vccontrs.ctdate, '99/99/9999').
      "
 &header = "ПАСПОРТА СДЕЛКИ/ДОП.ЛИСТА"
 &displcif = "true"
 &display = "
      vcps.dntype v-dntypename v-dnnum vcps.dndate vcps.lastdate vcps.ncrc v-nbcrckod
      vcps.sum vcps.cursdoc-con vcps.sum / vcps.cursdoc-con @ v-sumdoccon
      vcps.dnnote[1] vcps.dnnote[2] /*vcps.dnnote[3] vcps.dnnote[4] vcps.dnnote[5]*/ v-note
      /*vcps.rslc when vcps.rslc > 0*/ v-rslctype v-rslcdate v-rslcnum
      vcps.rdt vcps.rwho vcps.cdt vcps.cwho "
}

procedure defvars.
  find ncrc where ncrc.crc = vcps.ncrc no-lock no-error.
  if avail ncrc then do:
  v-nbcrckod = ncrc.code. end.
  else do: v-nbcrckod = ''. end.
  find codfr where codfr.codfr = "vcdoc" and codfr.code = vcps.dntype no-lock no-error.
  if avail codfr then v-dntypename = codfr.name[2]. else v-dntypename = "".
  find vcrslc where vcrslc.rslc = vcps.rslc no-lock no-error.
  if avail vcrslc then do:
    find codfr where codfr.codfr = "vcdoc" and codfr.code = vcrslc.dntype no-lock no-error.
    v-rslctype = codfr.name[1].
    v-rslcdate = vcrslc.dndate. v-rslcnum = vcrslc.dnnum.
  end.
  else do:
    v-rslctype = "". v-rslcdate = ?. v-rslcnum = "".
  end.
end.

