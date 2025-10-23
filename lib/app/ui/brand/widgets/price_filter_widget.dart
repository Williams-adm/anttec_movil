import 'package:flutter/material.dart';

class PriceFilterWidget extends StatefulWidget {
  const PriceFilterWidget({super.key});

  @override
  State<PriceFilterWidget> createState() => _PriceFilterWidgetState();
}

class _PriceFilterWidgetState extends State<PriceFilterWidget> {
  RangeValues _range = const RangeValues(50, 500);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Precio',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        RangeSlider(
          values: _range,
          min: 0,
          max: 1000,
          divisions: 20,
          labels: RangeLabels(
            'S/${_range.start.round()}',
            'S/${_range.end.round()}',
          ),
          onChanged: (values) {
            setState(() {
              _range = values;
            });
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Rango seleccionado: S/${_range.start.round()} - S/${_range.end.round()}',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
