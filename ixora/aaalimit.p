/* aaalimit.p 
 * MODULE
        Клиентская база
 * DESCRIPTION
        Блокирует сумму на счете получателя при помощи спец. инструкций для неснижаемого остатка
 * RUN
        
 * CALLER
        jou-aasnew2.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
      3-2-6  
 * AUTHOR
 * CHANGES
        30.03.2006 nataly - выделено из jou-aasnew2.p
        27/04/2006 nataly  - добавлена проверка на исключения по коду 193,180/181
*/

      def var v-aaa like aaa.aaa no-undo.
      def var v-sumlim as decimal init 0 no-undo.

   def button  btn1  label "Блокировка счета".
   def button  btn2  label "Разблокировка счета".
   def button  btn3  label "Выход".
   def frame   frame1
   skip(1) btn1 btn2 btn3 with centered title "Выберете тип отперации:" row 5 .
   def var prz as integer no-undo.

  on choose of btn1,btn2,btn3 do:
    if self:label = "Блокировка счета" then prz = 1.
    else
    if self:label = "Разблокировка счета" then prz = 2.
    else prz = 3.
   end.
   enable all with frame frame1.
    wait-for choose of btn1, btn2, btn3.
    if prz = 3 then return.
 hide  frame frame1.
      
       update v-aaa label 'Введите счет клиента' 
         validate (can-find (aaa  no-lock where aaa.aaa = v-aaa),'Счет не найден!') with                 frame ss   centered.
       find aaa where aaa.aaa = v-aaa no-lock no-error.
       find cif where cif.cif  = aaa.cif no-lock no-error .
       find lgr where lgr.lgr = aaa.lgr no-lock no-error .
       find first aas where aas.aaa = v-aaa and aas.payee begins 'Неснижаемый остаток ОД |'            no-lock no-error.

 /*блокировка*/
     if prz = 1 then do:
       if avail aas then do:
           message 'Неснижаемый остаток уже заблокирован!' view-as alert-box. 
           return.
        end.   

      find tarif2 where tarif2.num + tarif2.kod eq '193' and tarif2.stat = 'r' no-lock no-error.
      if avail tarif2 then find first tarifex2 where tarifex2.aaa = v-aaa and tarifex2.cif = cif.cif and tarifex2.str5 = '193' and tarifex2.stat = 'r' no-lock no-error.
      /*если нет исключений по счету, то берем сумму из справочника codfr*/
      if avail tarif2 and not avail tarifex2 then do:
        find codfr where codfr.codfr = 'clnlim' and codfr.code = string(aaa.crc) no-lock no-error.
        if avail codfr then v-sumlim = decimal(codfr.name[1]).  
      end.
      /* если есть исключение по счету и сумма заморозки > 0 , то берем сумму из tarifex2 */
      else if avail tarifex2 and tarifex2.ost <> 0 then do:
            v-sumlim = tarifex2.ost.
      end.
       if v-sumlim > 0 then do:
        if aaa.cr[1] - aaa.dr[1] < v-sumlim  then 
         do:
          find crc where crc.crc = aaa.crc no-lock no-error.
          message 'Остаток на счете ' v-aaa  skip 
           ' меньше неснижаемого остатка ' v-sumlim  crc.code skip 
           'Блокировка невозможна!'  view-as alert-box          title 'Внимание!'.
          return.
         end.
         else do:
          run jou-aasnew2 (v-aaa, v-sumlim,0).
          find first aas where aas.aaa = v-aaa and aas.payee begins 'Неснижаемый остаток ОД |'    no-lock no-error.
          if  avail aas then message 'Неснижаемый остаток успешно установлен!' view-as alert-box.
         end.
     end.
     end. /*блокировка*/

/*разблокировка */
     if prz = 2 then do:
       if not avail aas then do:
           message 'Неснижаемый остаток отсутствует!' view-as alert-box. 
           return.
        end.   
          run tdaremholdfiz(v-aaa).
       find first aas where aas.aaa = v-aaa and aas.payee begins 'Неснижаемый остаток ОД |'    no-lock no-error.
       if not avail aas then message 'Неснижаемый остаток успешно удален!' view-as alert-box.
     end.

