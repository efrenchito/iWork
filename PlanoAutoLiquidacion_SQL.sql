SELECT *
FROM   FND_LOOKUP_VALUES FLV
WHERE  FLV.LOOKUP_TYPE = 'XXMU_PAY_ABSENCE_DATES_DIST'
AND    FLV.LANGUAGE = 'ESA'
AND    SYSDATE BETWEEN FLV.START_DATE_ACTIVE AND NVL(FLV.END_DATE_ACTIVE, SYSDATE + 1)
AND    ENABLED_FLAG = 'Y'
;

--XXMU_PAY_AUTOPAY_PKG.CREATE_PLAIN_TEXT
SELECT *
FROM   fnd_lookup_values flv 
WHERE  flv.lookup_type = 'XXMU_PAY_ABSENCE_DATES_DIST'
AND    flv.language = 'ESA'
--AND    flv.lookup_code = 'A_0775'
;

-->>>>>>
--LEGAL_ENTITY
SELECT xle.legal_entity_id   --23277
      ,xle.legal_entity_name --PINTUCO S.A.
  FROM xxmu_pay_legal_entities_v xle
 WHERE xle.legal_entity_name = 'PINTUCO S.A.' 
     ;

--PAYROLL_INFO
SELECT xpi.payroll_id   --101 | 261
      ,xpi.payroll_name --GM_CO_NOMINA_MUNDIAL_CGP | GM_CO_NOMINA_MUNDIAL_CGP_JUB
  FROM xxmu_pay_payrolls_info_v xpi
 WHERE xpi.legal_entity_id = 23277
     ;

--TIME_PERIODS
SELECT time_period_id --13658 (01/08/2016 - 10/08/2016)
  FROM per_time_periods ptp
 WHERE PTP.Payroll_Id = 101 --GM_CO_NOMINA_MUNDIAL_CGP
   AND to_date('2016/08/01','YYYY/MM/DD') BETWEEN ptp.start_date AND ptp.end_date
     ;



DECLARE
  --p_legal_entity_id  NUMBER := 23277;
  --p_time_period_id   NUMBER := 13658;
  l_period           DATE;
  l_office           VARCHAR2(10) := NULL;
  --
  l_nreg     NUMBER := 0;
  l_total    NUMBER;
  l_tmp      VARCHAR2(200);
  l_tmp_valor  NUMBER;
  l_porcentaje_aporte_sena  NUMBER;
  l_has_error  BOOLEAN := FALSE;
  --
  g_period_start DATE := TO_DATE('2016/10/01', 'YYYY/MM/DD'); --'2016/08/01'
  g_period_end   DATE := TO_DATE('2016/10/10', 'YYYY/MM/DD'); --'2016/02/10'
  p_organization_id  NUMBER := 5489; --818
  p_payroll_id       NUMBER := 162;  --101
  p_office           VARCHAR2(1) := NULL;
  p_employee_type    VARCHAR2(15) := 'Empleado';
  g_period_text  VARCHAR2(20) := '2016/08/01 00:00:00'; --2016/08/01
  p_format           VARCHAR2(1) := 'C';
  p_office           VARCHAR2(1) := NULL;
  --
  xcerror EXCEPTION;
  x_error VARCHAR2(4000);
  x_city_code  VARCHAR2(10);
  x_dept_code  VARCHAR2(10);

  CURSOR c_employee IS
  SELECT xpea.person_id
        ,xpea.assignment_id
        ,xpea.doc_type
        ,xpea.doc_type_nomina
        ,xpea.doc_number
        ,xpea.name1
        ,xpea.name2
        ,xpea.last_name1
        ,xpea.last_name2
        ,(SELECT ppp.attribute5
            FROM per_pay_proposals ppp
           WHERE xpea.assignment_id = ppp.assignment_id
             AND ppp.change_date = (SELECT MAX(ppp2.change_date)
                                      FROM per_pay_proposals ppp2
                                     WHERE ppp.assignment_id = ppp2.assignment_id
                                       AND xxmu_pay_utils_pkg.overlaps_dates(&g_period_start, &g_period_end, ppp2.change_date, ppp2.date_to ) = 'Y')
         ) tipo_salario
        ,xpea.hr_organization_id
        ,xnov.ingreso
        ,xnov.retiro
        ,xnov.tda
        ,xnov.taa
        ,xnov.tdp
        ,xnov.tap
        ,xnov.vsp
        ,xnov.vst
        ,xnov.sln
        ,xnov.ige
        ,xnov.lma
        ,xnov.vac
        ,xnov.vct
        ,xrie.dias_incapacidad irp
        ,xpen.entidad     admin_pen
        ,xeps.entidad     admin_sal
        ,xpar.entidad_ccf admin_ccf
        ,xrie.entidad     admin_rie
        ,xpen.dias dias_pen
        ,xeps.dias dias_sal
        ,xrie.dias dias_rie
        ,xpar.dias dias_par
        ,xeps.salario_base salario_base_eps
        ,xpen.ibc_real ibc_pen
        ,xeps.ibc_real ibc_sal
        ,xrie.ibc_real ibc_rie
        ,xpar.ibc_real ibc_ccf
        ,xpen.total_aporte total_pen
        ,xeps.total_aporte total_sal
        ,xrie.aporte_obligatorio total_rie
        ,xeps.aporte_upc
        ,xeps.aporte_subsistencia
        ,xrie.centro_trabajo
        ,xrie.porcentaje porc_riesgos
        ,xpen.aporte_solidaridad
        ,xpen.aporte_vol_empresa
        ,xpen.aporte_vol_empleado
        ,xpen.subcta_sol_pensional
        ,xpen.subcta_sol_subsist
        ,xpen.valores_no_retenidos
        ,xpar.aporte_ccf
        ,xpar.aporte_sena
        ,xpar.aporte_icbf
        --,xpar.exonerado --ALM_001721
        ,xeps.exonerado --ALM_002965
        ,xass.tipo_cotizante_id
        ,xass.subtipo_cotizante_id
        ,0 tarifa_esap
        ,0 aporte_esap
        ,0 tarifa_men
        ,0 aporte_men
        --@ediaz20170214>>>
        ,CASE WHEN DECODE(ppf.current_employee_flag,'Y',pps.date_start,DECODE(ppf.current_npw_flag, 'Y', ppp.date_start, NULL)) 
                   BETWEEN &g_period_start AND &g_period_end 
                   THEN DECODE(ppf.current_employee_flag,'Y',pps.date_start,DECODE(ppf.current_npw_flag, 'Y', ppp.date_start, NULL))
              ELSE NULL
        END hire_date
        ,CASE WHEN pps.actual_termination_date BETWEEN &g_period_start AND &g_period_end THEN pps.actual_termination_date END actual_termination_date
        --@ediaz20170214<<<
        --@ediaz20170215>>>
        ,parafisc.aei_information12 ibc_otros
        ,autoliq_novedades.aei_information18 horas_laboradas
        --@ediaz20170215<<<
    FROM (SELECT xpa.assignment_id
                ,MAX(xpa.effective_end_date) end_date
            FROM xxmu_pay_assignments_v xpa
           WHERE xpa.organization_id = TO_CHAR(&p_organization_id)
             AND xpa.payroll_id = &p_payroll_id
             AND xpa.assignment_status_type_id = 1
             AND xxmu_pay_utils_pkg.overlaps_dates(&g_period_start, &g_period_end, xpa.effective_start_date, xpa.effective_end_date ) = 'Y'
          GROUP BY xpa.assignment_id) emp
        ,xxmu_pay_employ_assignments_v xpea
        ,xxmu_pay_autoliq_pension_v    xpen
        ,xxmu_pay_autoliq_salud_v      xeps
        ,xxmu_pay_autoliq_riesgos_v    xrie
        ,xxmu_pay_autoliq_paraf_v      xpar
        ,xxmu_pay_gm_co_aux_seg_soc_v  xass
        ,xxmu_pay_autoliq_novedad_v    xnov
        --@ediaz20170215>>>
        ,per_all_people_f ppf
        ,per_periods_of_service   pps
        ,per_periods_of_placement ppp
        --@ediaz20170215<<<
        --@ediaz20170214>>>
        ,per_assignment_extra_info autoliq_novedades
        ,per_assignment_extra_info parafisc
        --@ediaz20170214<<<

   WHERE 1 = 1
     --@ediaz20170215>>>
     AND autoliq_novedades.information_type = 'GM_CO_AUTOLIQ_NOVEDADES'
     AND autoliq_novedades.assignment_id = xpea.assignment_id
     AND autoliq_novedades.aei_information1 = &g_period_text
     AND parafisc.aei_information_category = 'GM_CO_AUTOLIQUIDACION_PARAFISC'
     AND parafisc.assignment_id = xpea.assignment_id
     AND parafisc.aei_information1 = &g_period_text
     --@ediaz20170215<<<
     --@ediaz20170214>>>
     AND ppf.person_id = xpea.person_id
     AND ppf.effective_start_date = xpea.emp_start_date 
     AND ppf.effective_end_date = xpea.emp_end_date
         --
     AND ppf.person_id = pps.person_id(+)
     AND (ppf.employee_number IS NULL 
          OR (ppf.employee_number IS NOT NULL 
             AND pps.date_start = (SELECT MAX(pps1.date_start)
                                     FROM per_periods_of_service pps1
                                    WHERE pps1.person_id = ppf.person_id
                                      AND pps1.date_start <= ppf.effective_end_date)))
         --
     AND ppf.person_id = ppp.person_id(+)
     AND (ppf.npw_number IS NULL 
          OR (ppf.npw_number IS NOT NULL 
             AND ppp.date_start = (SELECT MAX(ppp1.date_start)
                                     FROM per_periods_of_placement ppp1
                                    WHERE ppp1.person_id = ppf.person_id
                                      AND ppp1.date_start <= ppf.effective_end_date)))
     --@ediaz20170214<<<
     AND emp.assignment_id = xpea.assignment_id
     AND emp.end_date = xpea.ass_end_date
     AND emp.end_date BETWEEN xpea.emp_start_date AND xpea.emp_end_date
     AND xxmu_pay_autopay_pkg.has_access_to_office(xpea.assignment_id, &g_period_start, &p_office) = 'Y'
     AND xpea.employee_type = &p_employee_type
     -- Pensiones
     AND xpea.assignment_id = xpen.assignment_id(+)
     AND xpen.periodo(+) = &g_period_text
     -- Salud - EPS
     AND xpea.assignment_id = xeps.assignment_id(+)
     AND xeps.periodo(+) = &g_period_text
     -- Riesgos
     AND xpea.assignment_id = xrie.assignment_id(+)
     AND xrie.periodo(+) = &g_period_text
     -- Parafiscales
     AND xpea.assignment_id = xpar.assignment_id(+)
     AND xpar.periodo(+) = &g_period_text
     -- Aux Seg Social
     AND xpea.assignment_id = xass.assignment_id(+)
     AND xass.aplicacion(+) = xxmu_pay_autopay_pkg.gm_co_aux_seg_soc_date(xpea.assignment_id, &g_period_start)
     -- Novedades
     AND xpea.assignment_id = xnov.assignment_id(+)
     AND xnov.periodo(+) = &g_period_text
  ORDER BY xpea.full_name, xpea.ass_start_date;


  
BEGIN
  --p_organization_id := xxmu_pay_utils_pkg.get_org_id_from_legal_entity(p_legal_entity_id);
  sys.dbms_output.put_line('p_organization_id: '||p_organization_id);
  --l_period := xxmu_pay_utils_pkg.get_time_period_end(p_time_period_id);
  --l_period := TRUNC(l_period, 'MM');
  --sys.dbms_output.put_line('l_period: '||l_period);
  --g_period_text := xxmu_pay_utils_pkg.get_format_date(TRUNC(l_period, 'MM'));
  --g_period_start := l_period;
  --g_period_end   := LAST_DAY(l_period);
  sys.dbms_output.put_line('g_period_text: '||g_period_text);
  sys.dbms_output.put_line('g_period_start: '||g_period_start);
  sys.dbms_output.put_line('g_period_end: '||g_period_end);
  
  l_porcentaje_aporte_sena  := xxmu_pay_utils_pkg.porcentaje_aporte_sena/100;
  -- Recorre los empleados
  FOR r_emp IN c_employee LOOP
      --sys.dbms_output.put_line(c_employee%ROWCOUNT);
      /*01*/sys.dbms_output.put('02');
      /*02*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_integer(l_nreg, 5));
        -- Valida el tipo de documento
        IF r_emp.doc_type_nomina IS NULL THEN
          x_error := 'Empleado (' || r_emp.doc_number || ') -> No Tiene Tipo de Documento';
          l_has_error := TRUE;
          RAISE XCERROR; --ERROR(g_act_module, x_error, g_act_step);
        END IF;
      /*03*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_text( r_emp.doc_type_nomina, 2 ));
      /*04*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_text( r_emp.doc_number, 16 ));
        -- Valida los parafiscales
        IF r_emp.admin_ccf IS NULL THEN
          x_error := 'Empleado (' || r_emp.doc_number || ') -> No Tiene Parafiscales';
          l_has_error := TRUE;
          RAISE XCERROR; --ERROR(g_act_module, x_error, g_act_step);
        END IF;
        -- Valida las novedades
        IF r_emp.ingreso IS NULL THEN
          x_error := 'Empleado (' || r_emp.doc_number || ') -> No Tiene Novedades';
          l_has_error := TRUE;
          RAISE XCERROR; --ERROR(g_act_module, x_error, g_act_step);
        END IF;
        -- Valida las pensiones
        IF r_emp.admin_pen IS NULL THEN
          x_error := 'Empleado (' || r_emp.doc_number || ') -> No Tiene Pensiones';
          l_has_error := TRUE;
          RAISE XCERROR; --ERROR(g_act_module, x_error, g_act_step);
        END IF;
        -- Valida la salud
        IF r_emp.admin_sal IS NULL THEN
          x_error := 'Empleado (' || r_emp.doc_number || ') -> No Tiene Salud';
          l_has_error := TRUE;
          RAISE XCERROR; --ERROR(g_act_module, x_error, g_act_step);
        END IF;
        -- Valida los riesgos
        IF r_emp.admin_rie IS NULL THEN
          x_error := 'Empleado (' || r_emp.doc_number || ') -> No Tiene Riesgos';
          l_has_error := TRUE;
          RAISE XCERROR; --ERROR(g_act_module, x_error, g_act_step);
        END IF;
        -- Valida el tipo de salario
        IF r_emp.tipo_cotizante_id IS NULL OR r_emp.subtipo_cotizante_id IS NULL THEN
          x_error := 'Empleado (' || r_emp.doc_number || ') -> No Tiene Tipo o Subtipo de Cotizante';
          l_has_error := TRUE;
          RAISE XCERROR; --ERROR(g_act_module, x_error, g_act_step);
        END IF;
        /*05*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_integer( r_emp.tipo_cotizante_id, 2 ));
        /*06*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_integer( r_emp.subtipo_cotizante_id, 2 ));
        /*07*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_text( '', 1 ));
        /*08*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_text( '', 1 ));
        --Consulta los codigos DANE PARA LA ciudad
        --get_codigo_dane_base( get_ciudad_ccf(r_emp.assignment_id ),x_dane_code, x_dept_code, x_city_code );
        /*09*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_text( x_dept_code, 2 ));
        /*10*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_text( x_city_code, 3 ));
        /*11*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_text( r_emp.last_name1, 20 ));
        /*12*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_text( r_emp.last_name2, 30 ));
        /*13*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_text( r_emp.name1, 20 ));
        /*14*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_text( r_emp.name2, 30 ));
        /*15*/sys.dbms_output.put(xxmu_pay_utils_pkg.tox(r_emp.ingreso));
        /*16*/sys.dbms_output.put(xxmu_pay_utils_pkg.tox(r_emp.retiro));
        /*17*/sys.dbms_output.put(xxmu_pay_utils_pkg.tox(r_emp.tda));
        /*18*/sys.dbms_output.put(xxmu_pay_utils_pkg.tox(r_emp.taa));
        /*19*/sys.dbms_output.put(xxmu_pay_utils_pkg.tox(r_emp.tdp));
        /*20*/sys.dbms_output.put(xxmu_pay_utils_pkg.tox(r_emp.tap));
        /*21*/sys.dbms_output.put(xxmu_pay_utils_pkg.tox(r_emp.vsp));
        /*22*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_text( '', 1 ));
        /*23*/sys.dbms_output.put(xxmu_pay_utils_pkg.tox(r_emp.vst));
        /*24*/sys.dbms_output.put(xxmu_pay_utils_pkg.tox(r_emp.sln));
        /*25*/sys.dbms_output.put(xxmu_pay_utils_pkg.tox(r_emp.ige));
        /*26*/sys.dbms_output.put(xxmu_pay_utils_pkg.tox(r_emp.lma));
        /*27*/sys.dbms_output.put(xxmu_pay_utils_pkg.tox(r_emp.vac));
        l_tmp := (CASE WHEN r_emp.aporte_vol_empleado + r_emp.aporte_vol_empresa > 0 THEN 'X' ELSE '' END);
        /*28*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_text( l_tmp, 1 ));
        /*29*/sys.dbms_output.put(xxmu_pay_utils_pkg.tox(r_emp.vct));
        /*30*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_integer( r_emp.irp, 2 ));
        /*31*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_text( NULLIF(r_emp.admin_pen, '0000'), 6 ));
        --l_tmp := get_next_entidad_pension(r_emp.tap, r_emp.assignment_id, g_period_start, x_error);
        /*32*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_text( NULLIF(l_tmp, '0000'), 6 ));
        /*33*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_text( NULLIF(r_emp.admin_sal, '0000'), 6 ));
        --l_tmp := get_next_entidad_salud(r_emp.taa, r_emp.assignment_id, g_period_start, x_error);
        /*34*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_text( NULLIF(l_tmp, '0000'), 6 ));
        /*35*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_text( NULLIF(r_emp.admin_ccf, '0000'), 6 ));
        /*36*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_integer( r_emp.dias_pen, 2 ));
        /*37*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_integer( r_emp.dias_sal, 2 ));
        /*38*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_integer( r_emp.dias_rie, 2 ));
        /*39*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_integer( r_emp.dias_par, 2 ));
        /*40*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_integer( r_emp.salario_base_eps, 9 ));
        -- Valida el tipo de salario
        IF r_emp.tipo_salario IS NULL THEN
          x_error := 'Empleado (' || r_emp.doc_number || ') -> No Tiene Tipo de Salario';
          l_has_error := TRUE;
          RAISE XCERROR; --ERROR(g_act_module, x_error, g_act_step);
        END IF;
        l_tmp := (CASE r_emp.tipo_salario WHEN 'INTEGRAL' THEN 'X' ELSE '' END );
        /*41*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_text( l_tmp, 1 ));
        l_tmp_valor := r_emp.ibc_pen;
        /*42*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_integer( l_tmp_valor, 9 ));
        l_tmp_valor := r_emp.ibc_sal;
        /*43*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_integer( l_tmp_valor, 9 ));
        l_tmp_valor := r_emp.ibc_rie;
        /*44*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_integer( l_tmp_valor, 9 ));
        l_tmp_valor := r_emp.ibc_ccf;
        /*45*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_integer( l_tmp_valor, 9 ));
        -----  *** Variables de Autoliquidaci?n Sistema General de Pensiones
        l_total := (CASE WHEN r_emp.admin_pen <> '0000'
                         THEN xxmu_pay_utils_pkg.porcentaje_aporte_pension/100
                         ELSE 0 END);
        /*46*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_decimal( l_total, 7, 0 ));
        /*47*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_integer( r_emp.total_pen, 9 ));
        /*48*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_integer( r_emp.aporte_vol_empleado, 9 ));
        /*49*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_integer( r_emp.aporte_vol_empresa, 9 ));
        l_total := r_emp.total_pen + r_emp.aporte_vol_empleado + r_emp.aporte_vol_empresa;
        /*50*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_integer( l_total, 9 )); -- suma 47 48 49
        /*51*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_integer( r_emp.subcta_sol_pensional, 9 ));
        /*52*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_integer( r_emp.subcta_sol_subsist, 9 ));
        /*53*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_integer( r_emp.valores_no_retenidos, 9 ));
        -----  *** Variables de Autoliquidaci?n Sistema General de Seguridad Social en Salud
              l_total :=  (CASE  when r_emp.exonerado = 'NO' then
                                                xxmu_pay_utils_pkg.porcentaje_aporte_salud/100
                                        when r_emp.exonerado = 'SI' then
                                                xxmu_pay_utils_pkg.porcentaje_aporte_salud('E')/100
                             end);
        /*54*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_decimal( l_total, 7, 0 ));
        /*55*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_integer(  r_emp.total_sal, 9 ));
        /*56*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_integer( r_emp.aporte_upc, 9 ));
        /*57*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_text( '', 15 ));
        /*58*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_integer( 0, 9 ));
        /*59*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_text( '', 15 ));
        /*60*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_integer( 0, 9 ));
        -----  *** Variables de Autoliquidaci?n Sistema General de Riesgos Profesionales
        l_total := r_emp.porc_riesgos/100;
        /*61*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_decimal( l_total, 9, 0 ));
        /*62*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_integer( r_emp.centro_trabajo, 9 ));
        /*63*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_integer( r_emp.total_rie, 9 ));
        -----  *** Variables de Autoliquidaci?n de Parafiscales (Cajas de Compensaci?n Familiar, SENA y ICBF)
        l_total := (CASE WHEN r_emp.admin_ccf <> '0000'
                         THEN xxmu_pay_utils_pkg.porcentaje_aporte_ccf/100
                         ELSE 0 END);
        /*64*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_decimal( l_total, 7, 0 ));
        /*65*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_integer( r_emp.aporte_ccf, 9 ));
        l_total := (CASE WHEN r_emp.admin_ccf <> '0000'
                      THEN CASE  when r_emp.exonerado = 'NO' then
                                l_porcentaje_aporte_sena
                                 else
                                0 end
                         ELSE 0 END);
        /*66*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_decimal( l_total, 7, 0 ));
        /*67*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_integer( r_emp.aporte_sena, 9 ));
        l_total := (CASE WHEN r_emp.admin_ccf <> '0000'
                         THEN CASE  when r_emp.exonerado = 'NO' then
                              xxmu_pay_utils_pkg.porcentaje_aporte_icbf/100
                              else
                                0 end
                         ELSE 0 END);
        /*68*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_decimal( l_total, 7, 0 ));
        /*69*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_integer( r_emp.aporte_icbf, 9 ));
        /*70*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_decimal( r_emp.tarifa_esap, 7, 0 ));
        /*71*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_integer( r_emp.aporte_esap, 9 ));
        /*72*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_decimal( r_emp.tarifa_men, 7, 0 ));
        /*73*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_integer( r_emp.aporte_men, 9 ));
        /*74y75*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_text( '', 18 ));
        /*76*/sys.dbms_output.put(xxmu_pay_utils_pkg.tox_conv(r_emp.Exonerado));
        --@ediaz20170215>>>
        /*77*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_text( '', 5 ));
        /*78*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_text( '', 1 ));
        /*79*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_text( '', 2 ));
        /*80*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_text( TO_CHAR(r_emp.hire_date, 'YYYY-MM-DD'), 10 )); --Fecha de ingreso 
        /*81*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_text( TO_CHAR(r_emp.actual_termination_date, 'YYYY-MM-DD'), 10 )); --Fecha de retiro
        /*82*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_text( '', 10 )); --Fecha Inicio VSP 
        /*83*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_text( '', 10 )); --Fecha Inicio SLN
        /*84*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_text( '', 10 )); --Fecha Fin SLN
        /*85*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_text( '', 10 )); --Fecha Inicio IGE
        /*86*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_text( '', 10 )); --Fecha Fin IGE
        /*87*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_text( '', 10 )); --Fecha Inicio LMA
        /*88*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_text( '', 10 )); --Fecha Fin LMA
        /*89*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_text( '', 10 )); --Fecha Inicio VAC-LR
        /*90*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_text( '', 10 )); --Fecha Fin VAC-LR
        /*91*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_text( '', 10 )); --Fecha Inicio VCT
        /*92*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_text( '', 10 )); --Fecha Fin VCT
        /*93*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_text( '', 10 )); --Fecha Inicio IRL
        /*94*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_text( '', 10 )); --Fecha Fin IRL
        /*95*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_text( r_emp.ibc_otros, 9 )); --IBC otros parafiscales
        /*96*/sys.dbms_output.put(xxmu_pay_utils_pkg.format_text( r_emp.horas_laboradas, 3 )); --Horas laboradas
        --@ediaz20170215<<<
              sys.dbms_output.put_line('');
        --- FIN ALM_001721
    END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    sys.dbms_output.put('...EXCEPTION...');
END;

/*23277, 101, 13658, Empleado, C,*/
--l_organization_id: 5489 --818
--p_payroll_id: 162 --101
--l_period: 01/08/16
--g_period_text: 2016/08/01 00:00:00
--g_period_start: 01/10/16 | 01/08/16
--g_period_end:   31/10/16 | 31/08/16
--P_EMPLOYEE_TYPE = 'Empleado'


--753
  SELECT xpea.person_id
        ,xpea.assignment_id
        ,xpea.doc_type
        ,xpea.doc_type_nomina
        ,xpea.doc_number

        ,xpea.name1
        ,xpea.name2
        ,xpea.last_name1
        ,xpea.last_name2

        ,(SELECT ppp.attribute5
            FROM per_pay_proposals ppp
           WHERE xpea.assignment_id = ppp.assignment_id
             AND ppp.change_date = (SELECT MAX(ppp2.change_date)
                                      FROM per_pay_proposals ppp2
                                     WHERE ppp.assignment_id = ppp2.assignment_id
                                       AND xxmu_pay_utils_pkg.overlaps_dates(&g_period_start, &g_period_end, ppp2.change_date, ppp2.date_to ) = 'Y')
         ) tipo_salario
        ,xpea.hr_organization_id

        ,xnov.ingreso
        ,xnov.retiro

        ,xnov.tda
        ,xnov.taa
        ,xnov.tdp
        ,xnov.tap
        ,xnov.vsp
        ,xnov.vst
        ,xnov.sln
        ,xnov.ige
        ,xnov.lma
        ,xnov.vac

        ,xnov.vct
        ,xrie.dias_incapacidad irp

        ,xpen.entidad     admin_pen
        ,xeps.entidad     admin_sal
        ,xpar.entidad_ccf admin_ccf
        ,xrie.entidad     admin_rie

        ,xpen.dias dias_pen
        ,xeps.dias dias_sal
        ,xrie.dias dias_rie
        ,xpar.dias dias_par

        ,xeps.salario_base salario_base_eps

        ,xpen.ibc_real ibc_pen
        ,xeps.ibc_real ibc_sal
        ,xrie.ibc_real ibc_rie
        ,xpar.ibc_real ibc_ccf

        ,xpen.total_aporte total_pen
        ,xeps.total_aporte total_sal
        ,xrie.aporte_obligatorio total_rie

        ,xeps.aporte_upc
        ,xeps.aporte_subsistencia

        ,xrie.centro_trabajo
        ,xrie.porcentaje porc_riesgos

        ,xpen.aporte_solidaridad

        ,xpen.aporte_vol_empresa
        ,xpen.aporte_vol_empleado
        ,xpen.subcta_sol_pensional
        ,xpen.subcta_sol_subsist
        ,xpen.valores_no_retenidos

        ,xpar.aporte_ccf
        ,xpar.aporte_sena
        ,xpar.aporte_icbf
        --,xpar.exonerado --ALM_001721
        ,xeps.exonerado --ALM_002965

        ,xass.tipo_cotizante_id
        ,xass.subtipo_cotizante_id

        ,0 tarifa_esap
        ,0 aporte_esap
        ,0 tarifa_men
        ,0 aporte_men

        --@ediaz20170214>>>
        ,CASE WHEN DECODE(ppf.current_employee_flag,'Y',pps.date_start,DECODE(ppf.current_npw_flag, 'Y', ppp.date_start, NULL)) 
                   BETWEEN &g_period_start AND &g_period_end 
                   THEN DECODE(ppf.current_employee_flag,'Y',pps.date_start,DECODE(ppf.current_npw_flag, 'Y', ppp.date_start, NULL))
              ELSE NULL
        END hire_date
        ,CASE WHEN pps.actual_termination_date BETWEEN &g_period_start AND &g_period_end THEN pps.actual_termination_date END actual_termination_date
        --@ediaz20170214<<<
        --@ediaz20170215>>>
        ,parafisc.aei_information12 ibc_otros
        ,autoliq_novedades.aei_information18 horas_laboradas
        --@ediaz20170215<<<

    FROM (
          SELECT xpa.assignment_id
                ,MAX(xpa.effective_end_date) end_date
            FROM xxmu_pay_assignments_v xpa

           WHERE 1 = 1 
             AND xpa.organization_id = TO_CHAR(&p_organization_id)
             AND xpa.payroll_id = &p_payroll_id
             AND xpa.assignment_status_type_id = 1

             AND xxmu_pay_utils_pkg.overlaps_dates(&g_period_start, &g_period_end, xpa.effective_start_date, xpa.effective_end_date ) = 'Y'
          GROUP BY xpa.assignment_id

         ) emp
        ,xxmu_pay_employ_assignments_v xpea
        ,xxmu_pay_autoliq_pension_v    xpen
        ,xxmu_pay_autoliq_salud_v      xeps
        ,xxmu_pay_autoliq_riesgos_v    xrie
        ,xxmu_pay_autoliq_paraf_v      xpar
        ,xxmu_pay_gm_co_aux_seg_soc_v  xass
        ,xxmu_pay_autoliq_novedad_v    xnov
        --
        ,per_all_people_f ppf
        ,per_periods_of_service   pps
        ,per_periods_of_placement ppp
        --
        ,per_assignment_extra_info autoliq_novedades
        ,per_assignment_extra_info parafisc

   WHERE 1 = 1
     --@ediaz20170215>>>
     AND autoliq_novedades.information_type = 'GM_CO_AUTOLIQ_NOVEDADES'
     AND autoliq_novedades.assignment_id = xpea.assignment_id
     AND autoliq_novedades.aei_information1 = &g_period_text
     AND parafisc.aei_information_category = 'GM_CO_AUTOLIQUIDACION_PARAFISC'
     AND parafisc.assignment_id = xpea.assignment_id
     AND parafisc.aei_information1 = &g_period_text
     --@ediaz20170215<<<
     --@ediaz20170214>>>
     AND ppf.person_id = xpea.person_id
     AND ppf.effective_start_date = xpea.emp_start_date 
     AND ppf.effective_end_date = xpea.emp_end_date
         --
     AND ppf.person_id = pps.person_id(+)
     AND (ppf.employee_number IS NULL 
          OR (ppf.employee_number IS NOT NULL 
             AND pps.date_start = (SELECT MAX(pps1.date_start)
                                     FROM per_periods_of_service pps1
                                    WHERE pps1.person_id = ppf.person_id
                                      AND pps1.date_start <= ppf.effective_end_date)))
         --
     AND ppf.person_id = ppp.person_id(+)
     AND (ppf.npw_number IS NULL 
          OR (ppf.npw_number IS NOT NULL 
             AND ppp.date_start = (SELECT MAX(ppp1.date_start)
                                     FROM per_periods_of_placement ppp1
                                    WHERE ppp1.person_id = ppf.person_id
                                      AND ppp1.date_start <= ppf.effective_end_date)))
     --@ediaz20170214<<<
     -----
     AND emp.assignment_id = xpea.assignment_id
     AND emp.end_date = xpea.ass_end_date
     AND emp.end_date BETWEEN xpea.emp_start_date AND xpea.emp_end_date

     AND xxmu_pay_autopay_pkg.has_access_to_office(xpea.assignment_id, &g_period_start, &p_office) = 'Y'
     AND xpea.employee_type = &p_employee_type

     -- Pensiones
     AND xpea.assignment_id = xpen.assignment_id(+)
     AND xpen.periodo(+) = &g_period_text

     -- Salud - EPS
     AND xpea.assignment_id = xeps.assignment_id(+)
     AND xeps.periodo(+) = &g_period_text

     -- Riesgos
     AND xpea.assignment_id = xrie.assignment_id(+)
     AND xrie.periodo(+) = &g_period_text

     -- Parafiscales
     AND xpea.assignment_id = xpar.assignment_id(+)
     AND xpar.periodo(+) = &g_period_text

     -- Aux Seg Social
     AND xpea.assignment_id = xass.assignment_id(+)
     AND xass.aplicacion(+) = xxmu_pay_autopay_pkg.gm_co_aux_seg_soc_date(xpea.assignment_id, &g_period_start)

     -- Novedades
     AND xpea.assignment_id = xnov.assignment_id(+)
     AND xnov.periodo(+) = &g_period_text
     

  ORDER BY xpea.full_name, xpea.ass_start_date;


---
SELECT CASE WHEN hire_date BETWEEN TO_DATE('2016/10/01', 'YYYY/MM/DD') AND TO_DATE('2016/10/31', 'YYYY/MM/DD') THEN
         hire_date
        ELSE NULL
       END CASE hire_date
      CASE WHEN actual_termination_date BETWEEN TO_DATE('2016/10/01', 'YYYY/MM/DD') AND TO_DATE('2016/10/31', 'YYYY/MM/DD') THEN
        actual_termination_date
        ELSE NULL
      END CASE actual_termination_date
SELECT CASE WHEN DECODE(ppf.current_employee_flag,
                  'Y',
                  pps.date_start,
                  DECODE(ppf.current_npw_flag, 'Y', ppp.date_start, NULL)) hire_date
        ,pps.actual_termination_date
        ,ppf.FULL_NAME
        ,ppf.effective_start_date 
        ,ppf.effective_end_date
        ,ppf.person_id
      --INTO x_return
      FROM per_people_f             ppf
          ,per_periods_of_service   pps
          ,per_periods_of_placement ppp
     WHERE 1 = 1 --ppf.person_id = 75167 --p_person_id
       AND xxmu_pay_utils_pkg.overlaps_dates(p_date11 => TO_DATE('2016/10/01', 'YYYY/MM/DD')
                                            ,p_date12 => TO_DATE('2016/10/31', 'YYYY/MM/DD')
                                            ,p_date21 => ppf.effective_start_date
                                            ,p_date22 => ppf.effective_end_date) = 'Y'
       AND DECODE(ppf.current_employee_flag,
                  'Y',
                  pps.date_start,
                  DECODE(ppf.current_npw_flag, 'Y', ppp.date_start, NULL)) BETWEEN ppf.effective_start_date AND ppf.effective_end_date
       AND pps.actual_termination_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
       --AND &p_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
       AND ppf.person_id = pps.person_id(+)
       AND ppf.person_id = ppp.person_id(+)
       AND (ppf.employee_number IS NULL 
         OR (ppf.employee_number IS NOT NULL 
             AND pps.date_start = (SELECT MAX(pps1.date_start)
                                     FROM per_periods_of_service pps1
                                    WHERE pps1.person_id = ppf.person_id
                                      AND pps1.date_start <= ppf.effective_end_date)))
       AND (ppf.npw_number IS NULL 
         OR (ppf.npw_number IS NOT NULL 
             AND ppp.date_start = (SELECT MAX(ppp1.date_start)
                                     FROM per_periods_of_placement ppp1
                                    WHERE ppp1.person_id = ppf.person_id
                                      AND ppp1.date_start <= ppf.effective_end_date)));


SELECT autoliq_novedades.aei_information18 --HORAS_LABORADAS
FROM   per_assignment_extra_info autoliq_novedades
WHERE  autoliq_novedades.aei_information_category = 'GM_CO_AUTOLIQ_NOVEDADES'
  AND  autoliq_novedades.assignment_id = 36245
  AND  autoliq_novedades.aei_information1 = '2016/10/01 00:00:00'
;

SELECT parafisc.aei_information12 --IBC_OTROS
FROM   per_assignment_extra_info parafisc
WHERE  1 = 1
AND parafisc.aei_information_category = 'GM_CO_AUTOLIQUIDACION_PARAFISC'
--AND parafisc.assignment_id = xpea.assignment_id
AND TO_DATE(parafisc.aei_information1, 'YYYY/MM/DD HH24:MI:SS') BETWEEN &g_period_start AND &g_period_end
--AND parafisc.aei_information_category = 'GM_CO_AUTOLIQUIDACION_PARAFISC'
--AND parafisc.assignment_id = 36245
--AND TO_DATE(parafisc.aei_information1, 'YYYY/MM/DD HH24:MI:SS') BETWEEN TO_DATE('2016/10/01 00:00:00', 'YYYY/MM/DD HH24:MI:SS') AND TO_DATE('2016/10/31 00:00:00', 'YYYY/MM/DD HH24:MI:SS')
;
