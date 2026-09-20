/// قاموس الترجمة الشامل لتطبيق LUMCAL APP
/// يدعم اللغة العربية 100% واللغة الإنجليزية 100%
class AppStrings {
  static String get(String key, bool isArabic) {
    if (isArabic) {
      return _ar[key] ?? _en[key] ?? key;
    } else {
      return _en[key] ?? _ar[key] ?? key;
    }
  }

  static const Map<String, String> _ar = {
    'app_title': 'LUMCAL APP',
    'app_subtitle': 'by BOUGHABA ABDESSAMIE',
    'lang_toggle': 'EN',
    
    // التبويبات
    'tab_lighting': 'الإضاءة',
    'tab_cable': 'مقطع الكابل',
    'tab_short_circuit': 'تيار القصر والفصل',
    'nav_calculator': 'الحاسبة',
    'nav_standards': 'دليل معايير الإضاءة',
    'nav_project': 'مشروع المنزل',

    // الإنارة
    'lighting_title': 'حاسبة الإضاءة المنزلية',
    'lighting_banner': 'أدخل أبعاد الغرفة وشدة الإضاءة لحساب عدد اللمبات واستهلاك الطاقة واقتراح السلك والقاطع المناسب.',
    'room_name': 'اسم الدائرة / الفراغ:',
    'length_m': 'الطول (متر):',
    'width_m': 'العرض (متر):',
    'target_lux': 'شدة الإضاءة المطلوبة (Lux):',
    'bulb_lumen': 'لومين اللمبة (lm):',
    'bulb_watt': 'قدرة اللمبة (Watt):',
    'calculate': 'حساب وتحديث',
    'lighting_results': 'نتائج حساب الإضاءة',
    'room_area': 'المساحة',
    'total_lumens': 'إجمالي اللومين',
    'bulbs_count': 'عدد اللمبات',
    'total_watt': 'الاستهلاك الإجمالي',
    'wire_recommendation': 'توصية السلك والقاطع',
    'btn_size_cable': 'حساب الكابل ⬅',
    'btn_add_to_project': 'إضافة لمشروع المنزل',

    // الكابلات
    'cable_title': 'حساب مقطع السلك والكابل (IEC)',
    'cable_banner': 'حساب مقاطع الكابلات وفق معايير IEC 60364-5-52 الدقيقة مع مراعاة العزل، طريقة التمديد، والحرارة والتجاور.',
    'circuit_name_for_proj': 'اسم الدائرة / الفراغ (لربطه بالمشروع):',
    'phase_system': 'نظام الأطوار:',
    'voltage_v': 'الجهد (Voltage V):',
    'load_value': 'قيمة الحمل:',
    'load_type': 'نوع الحمل:',
    'power_factor': 'معامل القدرة (cos φ):',
    'cable_length_m': 'طول الكابل (متر):',
    'conductor_material': 'مادة الموصل:',
    'insulation_type': 'نوع العزل:',
    'installation_method': 'طريقة التمديد:',
    'temperature_c': 'الحرارة (°C):',
    'grouping_circuits': 'التجاور (دوائر):',
    'max_delta_v_pct': 'أقصى هبوط جهد ΔV (%):',
    'total_k_factor': 'معامل التصحيح الكلي:',
    'cable_results': 'التوصية الهندسية للمقطع',
    'recommended_section': 'المقطع المعتمد الموصى به:',
    'section_safety_note': 'يحقق كفاءة التحمل الحراري والأمان لهبوط الجهد معاً',
    'design_current_ib': 'تيار التصميم (Ib)',
    'min_section_delta_v': 'أدنى مقطع لهبوط الجهد (Min S)',
    'final_capacity_iz': 'سعة تحمل الكابل (Iz)',
    'recommended_breaker': 'القاطع المناسب',
    'actual_delta_v': 'هبوط الجهد الفعلي (Actual ΔV)',
    'btn_check_sc': 'فحص القصر ⬅',

    // تيار القصر
    'sc_title': 'تيار القصر ومنحنيات الفصل (IEC)',
    'sc_banner': 'حساب تيار القصر وفحص التحمل الحراري للكابل واختيار منحنى الفصل المناسب (Curves B, C, D, K, Z).',
    'upstream_isc': 'تيار قصر المنبع (Isc source kA):',
    'cable_section_mm2': 'مقطع الكابل (mm²):',
    'clearing_time_s': 'زمن فصل القاطع (t بالثواني):',
    'cb_specs_title': 'مواصفات القاطع الكهربائي (Circuit Breaker):',
    'rated_current_in': 'التيار الاسمي للقاطع (In):',
    'tripping_curve': 'منحنى الفصل (Tripping Curve):',
    'sc_results_title': 'نتائج فحص تيار القصر والفصل',
    'max_fault_current': 'أقصى تيار قصر (Isc max)',
    'min_fault_current': 'أدنى تيار قصر (Isc min)',
    'thermal_withstand_smin': 'التحمل الحراري (Min S req)',
    'max_permissible_length': 'أقصى طول مسموح (L max)',
    'mag_status_title': 'حالة الفصل المغناطيسي اللحظي',
    'mag_safe_trip': 'فصل لحظي آمن (t ≤ 0.1s) ✔',
    'mag_warning_trip': 'تحذير: لا يضمن فصلاً لحظياً ⚠️',
    'thermally_safe': 'الكابل محمي حرارياً ✔',
    'thermally_unsafe': 'تحذير: مقطع الكابل ضعيف حرارياً! ⚠️',

    // مشروع المنزل
    'project_summary_title': 'الملخص الإجمالي لمشروع المنزل',
    'unified_items': 'عناصر موحدة',
    'total_area': 'إجمالي المساحة',
    'total_load': 'إجمالي الحمل',
    'circuits_count': 'الدوائر والكابلات',
    'breakers_count': 'القواطع والحماية',
    'project_items_title': 'عناصر ودوائر المشروع المدمجة:',
    'btn_download_pdf': 'تحميل تقرير PDF بالإنجليزية',
    'btn_add_another': '+ إضافة دائرة أخرى',
    'item_added_success': 'تمت إضافة العنصر بنجاح إلى مشروع المنزل!',

    // دليل المعايير
    'standards_title': 'دليل معايير الإضاءة',
    'standards_banner': 'المرجع الهندسي الدولي لمستويات الإضاءة (CIBSE / EN 12464) ودرجات حرارة الألوان (Kelvin).',
  };

  static const Map<String, String> _en = {
    'app_title': 'LUMCAL APP',
    'app_subtitle': 'by BOUGHABA ABDESSAMIE',
    'lang_toggle': 'عربي',

    // Tabs
    'tab_lighting': 'Lighting',
    'tab_cable': 'Cable Sizing',
    'tab_short_circuit': 'Short-Circuit & CB',
    'nav_calculator': 'Calculator',
    'nav_standards': 'Lighting Standards',
    'nav_project': 'Home Project',

    // Lighting
    'lighting_title': 'Lighting Calculator',
    'lighting_banner': 'Enter room dimensions and target illuminance to calculate bulb count, power consumption, and recommended wiring.',
    'room_name': 'Circuit / Room Name:',
    'length_m': 'Length (m):',
    'width_m': 'Width (m):',
    'target_lux': 'Required Illuminance (Lux):',
    'bulb_lumen': 'Bulb Lumens (lm):',
    'bulb_watt': 'Bulb Wattage (W):',
    'calculate': 'Calculate & Update',
    'lighting_results': 'Lighting Calculation Results',
    'room_area': 'Room Area',
    'total_lumens': 'Total Lumens',
    'bulbs_count': 'Bulb Count',
    'total_watt': 'Total Load',
    'wire_recommendation': 'Recommended Wire & Breaker',
    'btn_size_cable': 'Size Cable ⬅',
    'btn_add_to_project': 'Add to Home Project',

    // Cables
    'cable_title': 'Cable Sizing Calculator (IEC)',
    'cable_banner': 'Precise cable sizing per IEC 60364-5-52 factoring in insulation, installation method, temperature, and grouping.',
    'circuit_name_for_proj': 'Circuit / Feeder Name (for project):',
    'phase_system': 'Phase System:',
    'voltage_v': 'Voltage (V):',
    'load_value': 'Load Value:',
    'load_type': 'Load Type:',
    'power_factor': 'Power Factor (cos φ):',
    'cable_length_m': 'Cable Length (m):',
    'conductor_material': 'Conductor Material:',
    'insulation_type': 'Insulation Type:',
    'installation_method': 'Installation Method:',
    'temperature_c': 'Temperature (°C):',
    'grouping_circuits': 'Grouping (Circuits):',
    'max_delta_v_pct': 'Max ΔV (%):',
    'total_k_factor': 'Total Correction Factor:',
    'cable_results': 'Recommended Cable Cross-Section',
    'recommended_section': 'Recommended Standard Section:',
    'section_safety_note': 'Satisfies both thermal ampacity and voltage drop criteria',
    'design_current_ib': 'Design Current (Ib)',
    'min_section_delta_v': 'Min Section for ΔV (Min S)',
    'final_capacity_iz': 'Cable Ampacity (Iz)',
    'recommended_breaker': 'Recommended Breaker',
    'actual_delta_v': 'Actual Voltage Drop (ΔV)',
    'btn_check_sc': 'Check Short-Circuit ⬅',

    // Short-Circuit
    'sc_title': 'Short-Circuit & Tripping Curves (IEC)',
    'sc_banner': 'Calculate fault currents, verify thermal withstand, and select tripping curve (Curves B, C, D, K, Z).',
    'upstream_isc': 'Upstream Fault Current (Isc source kA):',
    'cable_section_mm2': 'Cable Section (mm²):',
    'clearing_time_s': 'Clearing Time (t in seconds):',
    'cb_specs_title': 'Circuit Breaker Specifications:',
    'rated_current_in': 'Rated Current (In):',
    'tripping_curve': 'Tripping Curve:',
    'sc_results_title': 'Short-Circuit & Protection Results',
    'max_fault_current': 'Max Fault Current (Isc max)',
    'min_fault_current': 'Min Fault Current (Isc min)',
    'thermal_withstand_smin': 'Thermal Withstand (Min S req)',
    'max_permissible_length': 'Max Permissible Length (L max)',
    'mag_status_title': 'Instantaneous Magnetic Trip Status',
    'mag_safe_trip': 'Instantaneous Trip OK (t ≤ 0.1s) ✔',
    'mag_warning_trip': 'Warning: No Instantaneous Trip ⚠️',
    'thermally_safe': 'Thermally Protected ✔',
    'thermally_unsafe': 'Warning: Thermal Limit Exceeded! ⚠️',

    // Project
    'project_summary_title': 'Unified Home Project Summary',
    'unified_items': 'Unified Items',
    'total_area': 'Total Area',
    'total_load': 'Total Load',
    'circuits_count': 'Circuits & Cables',
    'breakers_count': 'Protection & Breakers',
    'project_items_title': 'Unified Project Circuits & Elements:',
    'btn_download_pdf': 'Download English PDF Report',
    'btn_add_another': '+ Add Another Circuit',
    'item_added_success': 'Item added to Home Project successfully!',

    // Standards
    'standards_title': 'Lighting Standards Guide',
    'standards_banner': 'International recommended illuminance levels (CIBSE / EN 12464) and color temperatures (Kelvin).',
  };
}
