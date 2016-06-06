/* cif-aaa.i
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
        BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        10.08.05 dpuchkov добавил просмотр сведений по инкассовым распоряжениям(клавиша F)
        16/10/2008 galina - подвинула фрейм bil на 10 позиций вправо
        20/10/2008 galina - явно указала ширину фрейма bil
        16/02/2009 galina - подвинула фрейм bil на 1 позиций вправо
        26/05/2009 galina - подвинула фрейм bil1 на 11 позиций вправо и явно указала его ширину
        06/08/2010 id00363 - Добавил историю пролонгаций
        29/04/2011 id00004 - Исправил некорректное отображение ставки в истории пролонгации.
        27/05/2011 evseev - исправил acvolt.x1 > '06/06/10' на date(acvolt.x1) > 06/06/10
        27/05/2011 evseev - Исправил некорректное отображение ставки в истории пролонгации.
        15.08.2011 ruslan - добавил C-Задолженность по счету
        07/10/2011 evseev - расширил поле vhbal и vavl
        10/01/2012 lyubov - добавила поле "Задолжнность перед Банком"
        11/10/2012 lyubov - добавила переменную для процедуры aaa-bal
        12/10/2012 lyubov - перекомпиляция
        16/10/2012 lyubov - обнулила переменные
*/

find first waaa no-lock no-error.
if not available waaa then do:
   {mesg.i 0205}.
   pause 2.
   return.
end.

def buffer baaa for aaa.
def buffer baaa1 for aaa.
def new shared var s-toavail like jl.dam.
def new shared var s-aaa like aaa.aaa.
def var aa5 as char format "x(8)".
def var vstat as char.
def var vbal like jl.dam.
def var vavl like jl.dam.
def var zdlj like jl.dam.
def var zdlj2 like jl.dam.
def var vhbal like jl.dam.
def var vfbal like jl.dam.
def var vcrline like jl.dam.
def var vcrlused like jl.dam.
def var vooo like aaa.aaa.
def var v-er as deci no-undo.

def var pr1 as char.
def var pr2 as char.

define variable ucif as character initial "cif".


{jabre.i
   &head = "waaa"
   &headkey = "aaa"
   &where = "true"
   &formname = "cifaaa"
   &framename = "cifaaa"
   &deletecon = "false"
   &addcon = "false"
   &prechoose = "
                  s-aaa = waaa.aaa. find baaa where baaa.aaa = waaa.aaa no-lock no-error.
     if lookup(baaa.lgr, '415,413,411,410,412') <> 0 then
        message 'Y-Информация по сейфовым ячейкам'. else
message 'Enter - обороты по счету; S - СПЕЦ.ИНСТР; U - остатки на уровнях; I - Доп. информация по счету ; D - Лимиты по дебету; P - Пролонгация;  L-Эффективная ставка(для депозитов) C-Задолженность по счету'.

if baaa.sta ne 'C' then do :
      run aaa-bal777(waaa.aaa, output vbal, output vavl, output vhbal,
          output vfbal, output vcrline, output vcrlused, output vooo).

         /*lyubov*/
   zdlj = 0.
   zdlj2 = 0.
   find aaa where aaa.aaa = waaa.aaa no-lock.
   find first cif where cif.cif = aaa.cif no-lock.
   for each bxcif where bxcif.cif = cif.cif no-lock:
       if bxcif.crc = 1 then zdlj = zdlj + bxcif.amount.
       else do:
           find last crchis where crchis.crc = bxcif.crc and crchis.whn <= bxcif.whn no-lock no-error.
           zdlj2 = bxcif.amount * crchis.rate[1].
           zdlj = zdlj + zdlj2.
       end.
   end.

      form skip(1)
           'Доступный остаток:  ' skip
           vavl format 'zzz,zzz,zzz,zzz,zz9.99-' skip
           '""""""""""""""""""""' skip
           'Задолженность перед Банком: ' skip
           zdlj format 'zzz,zzz,zzz,zzz,zz9.99-' skip
           '""""""""""""""""""""' skip
           'Задержанные средства' skip
           vfbal format 'zzzz,zzz,zzz,zz9.99-' skip
           '""""""""""""""""""""' skip
           'Заморож. средства:  ' skip
           vhbal format 'zzz,zzz,zzz,zzz,zz9.99-' skip
           '""""""""""""""""""""' skip
           'Откр.кредитная лин.:' skip
           vcrline format 'zzzz,zzz,zzz,zz9.99-' skip
           '""""""""""""""""""""' skip
           'Использ.кред. линия:' skip
           vcrlused format 'zzzz,zzz,zzz,zz9.99-'
           with overlay title 'Остатки'
           no-label column 70 row 5 width 32 frame bil.
      disp vavl zdlj vfbal vhbal vcrline vcrlused with  frame bil.
end. else do :
find first sub-cod where sub-cod.sub = 'cif' and
  sub-cod.acc = baaa.aaa and sub-cod.d-cod = 'clsa' no-lock no-error.
if avail sub-cod then do :
 find first codfr where codfr.codfr = sub-cod.d-cod and
  codfr.code = sub-cod.ccode  no-lock no-error.
  if avail codfr then do: pr1 = substr(codfr.name[1],1,15). pr2 = substr(codfr.name[1],16). end.
form skip(1)
   'Дата закрытия    :  ' skip
    sub-cod.rdt skip
    '""""""""""""""""""""' skip
   'Причина закрытия    ' skip
    pr1 format 'x(15)' skip
    '""""""""""""""""""""' skip
    pr2 format 'x(15)' skip
    '""""""""""""""""""""' skip(6)
    with overlay title 'Информация'
    no-label column 70 row 5 width 22 frame bil1.
    display sub-cod.rdt pr1 pr2 with frame bil1.
         end. end. "
   &predisplay = "find aaa where aaa.aaa = waaa.aaa no-lock. find lgr where lgr.lgr = aaa.lgr no-lock.
                  run aaa-bal777(waaa.aaa,output vbal,output vavl,output vhbal,
                   output vfbal, output vcrline, output vcrlused, output vooo).
                  if aaa.sta = 'C' then vstat = aaa.sta + '-закрыт'. else vstat = aaa.sta."
   &display = "aaa.aaa lgr.des vbal vstat"
   &highlight = "aaa.aaa lgr.des vbal vstat"
   &postkey = "else if keyfunction(lastkey) = 'return' then do:
 s-aaa = waaa.aaa. run aaa-trx.
 end.
 else if keyfunction(lastkey) = 'S' then do :
 s-aaa = waaa.aaa. run aastab .
 end .
 else if keyfunction(lastkey) = 'L' then do :

/*    run er_depf(aaa.lgr, aaa.opnamt, aaa.cla, aaa.rate, aaa.regdt, aaa.regdt, 0, 0, 0,output v-er). */
      find last acvolt where acvolt.aaa = waaa.aaa exclusive-lock no-error.
      if avail acvolt then
         message 'Эфективная ставка:' acvolt.x2 view-as alert-box title ''.
      else
         message 'Эфективная cтавка не найдена ' acvolt.x2 view-as alert-box title ''.

 end .
 else if keyfunction(lastkey) = 'U' then do :
 run amt_level (input ucif, input waaa.aaa).
 end .
 else if keyfunction(lastkey) = 'P' then do :
        /* История пролонгации */
	find first acvolt where acvolt.aaa = waaa.aaa no-lock no-error.
	if avail acvolt then do:
            find baaa1 where baaa1.aaa = waaa.aaa no-lock no-error.
            if date(acvolt.x1) > 06/06/10 then  do:
					message 'c' acvolt.x1 'по' acvolt.x3 '| % ставка:' baaa1.rate  view-as alert-box title ' История пролонгации '.
			end.
			else do:
					find first aaa where aaa.aaa20 = waaa.aaa no-lock no-error.
					message 'c' acvolt.x1 'по' acvolt.x3 '| % ставка:' baaa1.rate  view-as alert-box title ' История пролонгации '.

			end.

	end.

/*	if avail acvolt then do:
			if acvolt.x1 > '06/06/10' then  do:
				find first aaa where aaa.aaa20 = waaa.aaa no-lock no-error.

				find first accr where accr.aaa = aaa.aaa AND accr.fdt = date(acvolt.x1) + 1  no-lock no-error.
				if avail accr then do:
					message 'c' acvolt.x1 'по' acvolt.x3 '| % ставка:' accr.rate  view-as alert-box title ' История пролонгации '.
				end.
			        else do:
					message ' (20) не найдена ' view-as alert-box title ' История пролонгации '.
				end.


			end.
			else do:
				find first accr where accr.aaa = waaa.aaa AND accr.fdt = date(acvolt.x1) + 1  no-lock no-error.
				if avail accr then do:
					message 'c' acvolt.x1 'по' acvolt.x3 '| % ставка:' accr.rate  view-as alert-box title ' История пролонгации '.
				end.
			        else do:
					message ' (2) не найдена ' view-as alert-box title ' История пролонгации '.
				end.
			end.

	end.      */
        else do:
		message '(1) не найдена ' view-as alert-box title ' История пролонгации '.
	end.

 end .


  else if keyfunction(lastkey) = 'Y' then do :
      find last depo where depo.aaa = waaa.aaa and depo.prim2 <> 'del' no-lock no-error.
      if avail depo and depo.cell1 <> '' then
      message 'Депозитный счет:' depo.cell1 view-as alert-box title ''.
      else message 'Депозитный счет отсутствует' view-as alert-box title ''.
  end .
 else if keyfunction(lastkey) = 'I' then do :
  g-aaa = waaa.aaa. s-aaa = g-aaa.
  find aaa where aaa.aaa = g-aaa no-lock.
  find lgr where lgr.lgr = aaa.lgr no-lock.
  case lgr.led:
    when 'DDA' then run aaaq-dda.
    when 'SAV' then run aaaq-sav.
    when 'CDA' then run aaaq-cda.
    when 'CSA' then run aaaq-csa.
    when 'TDA' then run tdainfo1(input waaa.aaa).
  end case.
 hide frame faaa no-pause. hide frame aaa no-pause.
 find waaa where recid(waaa) = trec. curflag = 1.
 clear frame cifaaa all no-pause. next outer. end.
else if keyfunction(lastkey) = 'D' then run operdurs (input waaa.aaa, g-today).
 else if keyfunction(lastkey) = 'C' then do :
 s-aaa = waaa.aaa. run cli-dolg2 .
 end ."
   &end = "hide frame cifaaa. hide frame bil."
}

/*                   run cellinfo1(input waaa.aaa). */