import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/bcv_provider.dart';
import '../theme/app_theme.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _foreignController = TextEditingController();
  final TextEditingController _vesController = TextEditingController();

  final FocusNode _foreignFocus = FocusNode();
  final FocusNode _vesFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Focus listeners if needed, though mostly handled by onTap now
  }

  @override
  void dispose() {
    _foreignController.dispose();
    _vesController.dispose();
    _foreignFocus.dispose();
    _vesFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ratesAsyncValue = ref.watch(ratesProvider);
    final conversionState = ref.watch(conversionProvider);
    final customRates = ref.watch(customRatesProvider);

    // Determine active rate and comparison rate
    double activeRate = 0.0;
    double bcvComparisonRate = 0.0;
    CustomRate? currentCustomRate;

    if (ratesAsyncValue.hasValue) {
      final rates = ratesAsyncValue.value!;

      // Calculate BCV Rates for reference
      final isToday = conversionState.dateMode == RateDateMode.today;
      final usdRate = isToday ? rates.usdToday : rates.usdTomorrow;
      final eurRate = isToday ? rates.eurToday : rates.eurTomorrow;

      // Determine Comparison Base Rate (for Custom View)
      final useTomIfAvailable = rates.hasTomorrow;
      // Logic for comparison base: Usually compare against TOMORROW if available, else TODAY
      // But let's respect the user's toggle preference if we were implementing strict toggle.
      // However, for Custom Rate view, we have a specific comparisonBase toggle (USD/EUR).
      // Let's assume comparisonBase uses the "most relevant" rate (Tomorrow if exists).
      if (conversionState.comparisonBase == CurrencyType.usd) {
        bcvComparisonRate = useTomIfAvailable
            ? rates.usdTomorrow
            : rates.usdToday;
      } else {
        bcvComparisonRate = useTomIfAvailable
            ? rates.eurTomorrow
            : rates.eurToday;
      }

      // Determine Active Conversion Rate
      if (conversionState.currency == CurrencyType.custom) {
        final id = conversionState.selectedCustomRateId;
        if (customRates.isNotEmpty) {
          currentCustomRate = customRates.firstWhere(
            (r) => r.id == id,
            orElse: () => customRates.first,
          );
          activeRate = currentCustomRate.rate;

          // Ensure selected ID is valid in state
          if (conversionState.selectedCustomRateId != currentCustomRate.id) {
            Future.microtask(
              () => ref
                  .read(conversionProvider.notifier)
                  .setSelectedCustomRate(currentCustomRate!.id),
            );
          }
        }
      } else {
        // Standard USD/EUR
        if (conversionState.currency == CurrencyType.usd) {
          activeRate = usdRate;
        } else {
          activeRate = eurRate;
        }
      }
    }

    // Listener for State Updates to Controllers
    ref.listen<ConversionState>(conversionProvider, (previous, next) {
      if (_foreignController.text != next.foreignValue) {
        _foreignController.text = next.foreignValue;
        _foreignController.selection = TextSelection.fromPosition(
          TextPosition(offset: _foreignController.text.length),
        );
      }
      if (_vesController.text != next.vesValue) {
        _vesController.text = next.vesValue;
        _vesController.selection = TextSelection.fromPosition(
          TextPosition(offset: _vesController.text.length),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              // Toggles Row
              _buildToggles(
                conversionState,
                ratesAsyncValue.value?.hasTomorrow ?? false,
              ),
              const SizedBox(height: 10),

              // 1. Exchange Rate Display Card
              _buildRateCard(
                ratesAsyncValue,
                conversionState,
                currentCustomRate,
                bcvComparisonRate,
              ),
              const SizedBox(height: 24),

              // 2. Main Conversion Area
              if (ratesAsyncValue.isLoading)
                const Center(
                  child: CircularProgressIndicator(color: AppTheme.textAccent),
                )
              else if (ratesAsyncValue.hasError)
                const SizedBox.shrink()
              else
                _buildConversionCard(
                  activeRate,
                  conversionState,
                  ratesAsyncValue.value?.rateDate,
                  customRate: currentCustomRate,
                  bcvCompRate: bcvComparisonRate,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggles(ConversionState state, bool hasTomorrow) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Currency Toggle
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _buildToggleButton(
                "USD",
                state.currency == CurrencyType.usd,
                () => ref
                    .read(conversionProvider.notifier)
                    .setCurrency(CurrencyType.usd),
              ),
              _buildToggleButton(
                "EUR",
                state.currency == CurrencyType.eur,
                () => ref
                    .read(conversionProvider.notifier)
                    .setCurrency(CurrencyType.eur),
              ),
              _buildToggleButton(
                "Pers.",
                state.currency == CurrencyType.custom,
                () => ref
                    .read(conversionProvider.notifier)
                    .setCurrency(CurrencyType.custom),
              ),
            ],
          ),
        ),

        // Date Mode Toggle (Hoy / Mañana) - Only if NOT custom
        if (state.currency != CurrencyType.custom)
          Container(
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildToggleButton(
                  "Hoy",
                  state.dateMode == RateDateMode.today,
                  () => ref
                      .read(conversionProvider.notifier)
                      .setDateMode(RateDateMode.today),
                ),
                _buildToggleButton(
                  "Mañana",
                  state.dateMode == RateDateMode.tomorrow,
                  hasTomorrow
                      ? () => ref
                            .read(conversionProvider.notifier)
                            .setDateMode(RateDateMode.tomorrow)
                      : null,
                  showBadge: hasTomorrow,
                  isDisabled: !hasTomorrow,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildToggleButton(
    String text,
    bool isSelected,
    VoidCallback? onTap, {
    bool showBadge = false,
    bool isDisabled = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.textAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(
              text,
              style: TextStyle(
                color: isDisabled
                    ? AppTheme.textSubtle.withValues(alpha: 0.3)
                    : (isSelected ? Colors.white : AppTheme.textSubtle),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            if (showBadge) ...[
              const SizedBox(width: 6),
              Transform.translate(
                offset: const Offset(0, -3),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRateCard(
    AsyncValue<RatesData> ratesAsyncValue,
    ConversionState state,
    CustomRate? customRate,
    double bcvComparisonRate,
  ) {
    if (state.currency == CurrencyType.custom) {
      return _buildCustomRateCard(state, customRate, bcvComparisonRate);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text("Tasa Oficial BCV", style: AppTheme.subtitleStyle),
          const SizedBox(height: 10),

          ratesAsyncValue.when(
            data: (rates) {
              final isUsd = state.currency == CurrencyType.usd;
              final isToday = state.dateMode == RateDateMode.today;
              final rate = isUsd
                  ? (isToday ? rates.usdToday : rates.usdTomorrow)
                  : (isToday ? rates.eurToday : rates.eurTomorrow);
              final symbol = isUsd ? "USD" : "EUR";

              String dateStr = "---";
              if (rates.rateDate != null) {
                dateStr = DateFormat('dd/MM/yyyy').format(rates.rateDate!);
              }

              return Column(
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "1 $symbol = ",
                          style: AppTheme.rateLabelStyle,
                        ),
                        TextSpan(
                          text:
                              "${NumberFormat("#,##0.00", "es_VE").format(rate)} VES",
                          style: AppTheme.rateStyle,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Fecha Valor: $dateStr",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textSubtle.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              );
            },
            loading: () =>
                const CircularProgressIndicator(color: AppTheme.textAccent),
            error: (err, stack) => const Text(
              "Error cargando tasa",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomRateCard(
    ConversionState state,
    CustomRate? rate,
    double bcvComparisonRate,
  ) {
    final customRates = ref.watch(customRatesProvider);

    // Fallback if null (shouldn't happen if list not empty)
    if (rate == null && customRates.isNotEmpty) rate = customRates.first;
    if (rate == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.currency_exchange,
              color: AppTheme.textSubtle,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              "Crea tu primera tasa personalizada",
              style: AppTheme.subtitleStyle.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Agrega tasas de cambios personalizadas para calcular tus conversiones.",
              style: TextStyle(
                color: AppTheme.textSubtle.withValues(alpha: 0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.add, color: Colors.black),
              label: const Text(
                "Crear Tasa",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.textAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _showAddEditRateDialog(),
            ),
          ],
        ),
      );
    }

    double diff = 0.0;
    if (bcvComparisonRate > 0 && rate.rate > 0) {
      diff = ((rate.rate - bcvComparisonRate) / bcvComparisonRate) * 100;
    }

    final bcvLabel = state.comparisonBase == CurrencyType.usd
        ? "BCV USD"
        : "BCV EUR";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header: Partially Stacked to allow robust centering of title + right buttons
          SizedBox(
            height: 20,
            child: Stack(
              children: [
                // 1. Center: Dropdown or Title
                Align(
                  alignment: Alignment.center,
                  child: customRates.isEmpty
                      ? Text("Crea una tasa", style: AppTheme.subtitleStyle)
                      : DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: customRates.any((r) => r.id == rate!.id)
                                ? rate.id
                                : null,
                            dropdownColor: AppTheme.cardBackground,
                            style: AppTheme.subtitleStyle,
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: AppTheme.textAccent,
                            ),
                            items: customRates.map((r) {
                              return DropdownMenuItem(
                                value: r.id,
                                child: Text(r.name),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                ref
                                    .read(conversionProvider.notifier)
                                    .setSelectedCustomRate(val);
                              }
                            },
                          ),
                        ),
                ),

                // 2. Right: Buttons
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: AppTheme.textAccent,
                        ),
                        iconSize: 20,
                        onPressed: () => _showAddEditRateDialog(),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        tooltip: "Crear nueva tasa",
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: AppTheme.textSubtle,
                        ),
                        iconSize: 20,
                        onPressed: () => _showAddEditRateDialog(rate: rate),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        tooltip: "Editar tasa",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: "1 ${rate.name} = ",
                  style: AppTheme.rateLabelStyle,
                ),
                TextSpan(
                  text:
                      "${NumberFormat("#,##0.00", "es_VE").format(rate.rate)} VES",
                  style: AppTheme.rateStyle,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Comparison Row
          GestureDetector(
            onTap: () {
              final newBase = state.comparisonBase == CurrencyType.usd
                  ? CurrencyType.eur
                  : CurrencyType.usd;
              ref.read(conversionProvider.notifier).setComparisonBase(newBase);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "$bcvLabel: ${bcvComparisonRate.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: AppTheme.textSubtle,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(height: 12, width: 1, color: Colors.white24),
                  const SizedBox(width: 8),
                  Text(
                    "${diff >= 0 ? '+' : ''}${diff.toStringAsFixed(1)}%",
                    style: TextStyle(
                      color: diff >= 0 ? Colors.greenAccent : Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.swap_horiz,
                    color: AppTheme.textSubtle,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEditRateDialog({CustomRate? rate}) {
    final nameCtrl = TextEditingController(text: rate?.name ?? "");
    final rateCtrl = TextEditingController(text: rate?.rate.toString() ?? "");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        title: Text(
          rate == null ? "Nueva Tasa" : "Editar Tasa",
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              maxLength: 10, // Max 10 chars
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Nombre (Max 10)",
                counterStyle: TextStyle(color: AppTheme.textSubtle),
                labelStyle: TextStyle(color: AppTheme.textSubtle),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.textSubtle),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: rateCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Tasa (VES)",
                labelStyle: TextStyle(color: AppTheme.textSubtle),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.textSubtle),
                ),
              ),
            ),
          ],
        ),
        actions: [
          if (rate != null)
            TextButton(
              onPressed: () {
                ref.read(customRatesProvider.notifier).deleteRate(rate.id);
                Navigator.pop(ctx);
              },
              child: const Text(
                "Eliminar",
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "Cancelar",
              style: TextStyle(color: AppTheme.textSubtle),
            ),
          ),
          TextButton(
            onPressed: () {
              final val = double.tryParse(rateCtrl.text);
              if (nameCtrl.text.isNotEmpty && val != null) {
                // Also validate max length just in case
                if (nameCtrl.text.length > 10) return;

                if (rate == null) {
                  ref
                      .read(customRatesProvider.notifier)
                      .addRate(nameCtrl.text, val);
                } else {
                  ref
                      .read(customRatesProvider.notifier)
                      .updateRate(rate.id, nameCtrl.text, val);
                }
                Navigator.pop(ctx);
              }
            },
            child: const Text(
              "Guardar",
              style: TextStyle(color: AppTheme.textAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversionCard(
    double rate,
    ConversionState state,
    DateTime? rateDate, {
    CustomRate? customRate,
    double? bcvCompRate,
  }) {
    // Label & Prefix Logic
    String foreignLabel;
    String foreignPrefix;

    if (state.currency == CurrencyType.custom) {
      if (customRate != null) {
        foreignLabel = customRate.name;
      } else {
        foreignLabel = "Personalizada";
      }
      // No symbol for custom rates as requested
      foreignPrefix = "";
    } else {
      if (state.comparisonBase == CurrencyType.usd) {
        // However, this logic was slightly flawed in previous iterations.
        // If state.currency is USD, label should be Dólares.
        // If state.currency is EUR, label should be Euros.
        // The comparisonBase is only for Custom mode comparison.
        // For standard mode, we should check `state.currency`.
        // Let's fix this logic properly:
        if (state.currency == CurrencyType.usd) {
          foreignLabel = "Dólares";
          foreignPrefix = "\$ ";
        } else {
          foreignLabel = "Euros";
          foreignPrefix = "€ ";
        }
      } else {
        // Fallback or same
        if (state.currency == CurrencyType.usd) {
          foreignLabel = "Dólares";
          foreignPrefix = "\$ ";
        } else {
          foreignLabel = "Euros";
          foreignPrefix = "€ ";
        }
      }
    }

    // Simplification of the else block:
    /*
    } else {
       if (state.currency == CurrencyType.usd) {
         foreignLabel = "Dólares";
         foreignPrefix = "\$ ";
       } else {
         foreignLabel = "Euros";
         foreignPrefix = "€ ";
       }
    }
    */

    const String vesLabel = "Bolívares";
    const String vesPrefix = "Bs. ";

    // BCV Equivalence Logic (for Custom Rate mode)
    String? inputsHelper;
    String? resultsHelper;

    if (customRate != null && bcvCompRate != null && bcvCompRate > 0) {
      double val = double.tryParse(_foreignController.text) ?? 0.0;
      if (val > 0) {
        // Foreign Helper
        double totalVes = val * customRate.rate;
        double bcvPurchasingPower = totalVes / bcvCompRate;

        String symbol = state.comparisonBase == CurrencyType.usd ? "\$" : "€";
        inputsHelper =
            "$symbol ${NumberFormat("#,##0.00", "es_VE").format(bcvPurchasingPower)} (BCV)";

        // VES Helper
        double equivalentVesAtBcv = val * bcvCompRate;
        resultsHelper =
            "${NumberFormat("#,##0.00", "es_VE").format(equivalentVesAtBcv)} Bs (BCV)";
      }
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with Share Button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.share, color: AppTheme.textSubtle),
                onPressed: () =>
                    _shareConversion(rate, state, rateDate, customRate),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          // Foreign Input
          _buildInputField(
            controller: _foreignController,
            focusNode: _foreignFocus,
            label: foreignLabel,
            placeholder: "Monto",
            prefixText: foreignPrefix,
            onChanged: (value) {
              // validate with European format support
              final sanitized = value.replaceAll('.', '').replaceAll(',', '.');
              if (double.tryParse(sanitized) != null || value.isEmpty) {
                ref
                    .read(conversionProvider.notifier)
                    .updateForeign(value, rate);
              }
            },
            canCopy: true,
            helperText: inputsHelper,
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Icon(
              Icons.swap_vert_rounded,
              color: AppTheme.textSubtle,
              size: 24,
            ),
          ),

          // VES Input
          _buildInputField(
            controller: _vesController,
            focusNode: _vesFocus,
            label: vesLabel,
            placeholder: "Equivalente en VES",
            prefixText: vesPrefix,
            onChanged: (value) {
              final sanitized = value.replaceAll('.', '').replaceAll(',', '.');
              if (double.tryParse(sanitized) != null || value.isEmpty) {
                ref.read(conversionProvider.notifier).updateVES(value, rate);
              }
            },
            canCopy: true,
            helperText: resultsHelper,
          ),
        ],
      ),
    );
  }

  void _shareConversion(
    double rate,
    ConversionState state,
    DateTime? date,
    CustomRate? customRate,
  ) async {
    final foreignAmount = _foreignController.text;
    final vesAmount = _vesController.text;

    if (foreignAmount.isEmpty || vesAmount.isEmpty) return;

    String symbol = state.currency == CurrencyType.usd ? "\$" : "€";
    String rateName = "BCV";
    if (customRate != null) {
      symbol = customRate.name;
      rateName = customRate.name;
    }

    final formattedRate = NumberFormat("#,##0.00", "es_VE").format(rate);

    final msg =
        "El monto es $symbol$foreignAmount ($vesAmount Bs) | Tasa $rateName = $formattedRate Bs";

    try {
      final box = context.findRenderObject() as RenderBox?;
      // ignore: deprecated_member_use
      await Share.share(
        msg,
        sharePositionOrigin: box != null
            ? box.localToGlobal(Offset.zero) & box.size
            : null,
      );
    } catch (e) {
      debugPrint("Error sharing: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al compartir: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    required Function(String) onChanged,
    FocusNode? focusNode,
    bool canCopy = false,
    String? helperText,
    String? prefixText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTheme.inputLabelStyle),
            if (canCopy)
              GestureDetector(
                onTap: () {
                  if (controller.text.isNotEmpty) {
                    Clipboard.setData(ClipboardData(text: controller.text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Copiado al portapapeles"),
                        duration: Duration(milliseconds: 1000),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: const Icon(
                    Icons.copy,
                    color: AppTheme.textSubtle,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                focusNode: focusNode,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: AppTheme.inputTextStyle.copyWith(fontSize: 22),
                cursorColor: AppTheme.textAccent,
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: placeholder,
                  hintStyle: TextStyle(
                    color: AppTheme.textSubtle.withValues(alpha: 0.5),
                    fontSize: 20,
                  ),
                  prefixIcon: prefixText != null
                      ? Padding(
                          padding: const EdgeInsets.only(left: 20, right: 4),
                          child: Text(
                            prefixText,
                            style: AppTheme.inputTextStyle.copyWith(
                              color: AppTheme.textSubtle,
                              fontSize: 18,
                            ),
                          ),
                        )
                      : null,
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 0,
                    minHeight: 0,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(
                    left: prefixText != null ? 0 : 20,
                    right: 20,
                    top: 16,
                    bottom: helperText != null ? 4 : 16,
                  ),
                ),
              ),
              if (helperText != null)
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 8,
                  ),
                  child: Text(
                    helperText,
                    style: TextStyle(
                      color: AppTheme.textSubtle.withValues(alpha: 0.6),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
