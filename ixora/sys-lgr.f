 "form
          
          lgr.lgr lgr.des skip
          lgr.alt format ""x(2)"" label ""ACC TYPE"" skip
          lgr.avgbal format ""zz,zzz,zz9.99"" lgr.feemon skip
          lgr.chkmon lgr.feechk skip
          lgr.feensf lgr.stm skip
          lgr.complex lgr.base skip
          lgr.lookaaa  lgr.crc skip
          lgr.pri lgr.rate format ""zzzz.9999"" skip
          lgr.dueday lgr.laterat
          lgr.intcal lgr.intpay lgr.prd 

          lgr.autoext format 'zzz' label 'КНП'
          validate(can-find(codfr where codfr.codfr = 'spnpl' 
          and codfr.code = string(lgr.autoext,'999')) and lgr.autoext <> 'msc'
          ,'Неверное значение кода назначения платежа')

          lgr.tlev format '>>>' label 'Тип клиентов' help ' 1 - юрлицо, 2 - физлицо, 3 - ЧП'
          validate((can-find(codfr where codfr.codfr = 'lgrsts' 
          and codfr.code = trim(string(lgr.tlev))) and lgr.tlev <> 'msc') or lgr.tlev = 0
          ,'Неверное значение типа клиентов для группы счетов')  

          with frame xlgr 2 col row 4 centered overlay
          title "" Условия начисления процентов  ""."
