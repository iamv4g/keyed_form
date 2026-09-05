/// Represents a parsed field within a KS schema.
class ParsedField {
  ParsedField({
    required this.name,
    required this.dartType,
    this.isNullable = false,
    this.isOptional = false,
    this.defaultValue,
    this.isNestedObject = false,
    this.isList = false,
    this.nestedClass,
    this.listItemType,
    this.rules = const [],
  });

  final String name;
  final String dartType;
  final bool isNullable;
  final bool isOptional;
  final String? defaultValue;
  final bool isNestedObject;
  final bool isList;
  final ParsedClass? nestedClass;
  final String? listItemType;
  final List<String> rules;

  String get nonNullDartType => dartType.endsWith('?')
      ? dartType.substring(0, dartType.length - 1)
      : dartType;
}

/// Represents a parsed class generated from a KSObject schema.
class ParsedClass {
  ParsedClass({
    required this.name,
    required this.schemaName,
    this.isListItem = false,
    this.isFunction = false,
    required this.fields,
    this.refinements = const [],
    this.parentClass,
    this.listFieldNameInParent,
    this.isUnion = false,
    this.unionDiscriminator,
    this.unionVariants,
    this.unionBaseClass,
    this.unionDiscriminatorValue,
    this.ancestorListItems = const [],
  });

  final String name;
  final String schemaName;
  final bool isListItem;
  final bool isFunction;
  final List<ParsedField> fields;
  final List<({String testCode, String message, String path})> refinements;
  final ParsedClass? parentClass;
  final String? listFieldNameInParent;
  final bool isUnion;
  final String? unionDiscriminator;
  final Map<String, ParsedClass>? unionVariants;
  final ParsedClass? unionBaseClass;
  final String? unionDiscriminatorValue;
  final List<ParsedClass> ancestorListItems;
}
