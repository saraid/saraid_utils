# Modify the Object class to have two translation methods.
# * #to_sql translates the object into a single-quoted string.
class Object
  def to_sql
    "'#{self}'"
  end
end

class Numeric
  def to_sql
    "#{self}"
  end
end

# nil is represented as NULL in SQL, without single quotes.
class NilClass
  def to_sql
    'NULL'
  end
end

# true is represented as true in SQL, without single quotes.
class TrueClass
  def to_sql
    'true'
  end
end

# false is represented as false in SQL, without single quotes.
class FalseClass
  def to_sql
    'false'
  end
end

module SaraidSql
  class MultiRowUpdate
    def initialize(data, options)
      @data = data
      @options = options
    end
    attr_reader :data, :options

    def to_sql
      return nil if data.empty?
      value_column_name = options.fetch(:value_column_name)
      key_column_name = options.fetch(:key_column_name)
      value_column_value = options.fetch(:value_column_value, proc { |datum| datum.send(value_column_name.to_sym) })
      key_column_value = options.fetch(:key_column_value, proc { |datum| datum.send(key_column_name.to_sym) })
      comment = options.fetch(:comment, proc {})
      cases = data.map do |datum|
        [ "WHEN #{key_column_value.call(datum).to_sql}",
          "THEN #{value_column_value.call(datum).to_sql}",
          "-- #{comment.call(datum)}"
        ].join(' ')
      end.map { |string| ' '*5 + string }.unshift(nil)
      <<~SQL
        UPDATE #{options.fetch(:table)}
           SET #{value_column_name} = CASE #{key_column_name}#{cases.join($/)}
             ELSE #{value_column_name}
             END
         WHERE #{key_column_name} IN (#{data.map(&key_column_value).map(&:to_sql).join(', ')});
      SQL
    end
  end
end

begin
  require 'postgres'
rescue LoadError
end

if defined?(PostgresPR)
  module PostgresPRExtensions
    class PostgresError < StandardError
      def self.parse(exception)
        severity, v_something, error_class, error_message, file, line, function = exception.message.split("\t")

        error_class = error_class.match(/C(\w+)/)[1]
        error_message = error_message.match(/M(.+)/)[1]

        { code: error_class, message: error_message }
      end

      def self.[](code)
        (@registry ||= {})[code] || PostgresError.new
      end

      [ ["00000", "successful_completion", "SuccessfulCompletion_00000"],
        ["01000", "warning", "Warning_01000"],
        ["0100C", "dynamic_result_sets_returned", "DynamicResultSetsReturned_0100C"],
        ["01008", "implicit_zero_bit_padding", "ImplicitZeroBitPadding_01008"],
        ["01003", "null_value_eliminated_in_set_function", "NullValueEliminatedInSetFunction_01003"],
        ["01007", "privilege_not_granted", "PrivilegeNotGranted_01007"],
        ["01006", "privilege_not_revoked", "PrivilegeNotRevoked_01006"],
        ["01004", "string_data_right_truncation", "StringDataRightTruncation_01004"],
        ["01P01", "deprecated_feature", "DeprecatedFeature_01P01"],
        ["02000", "no_data", "NoData_02000"],
        ["02001", "no_additional_dynamic_result_sets_returned", "NoAdditionalDynamicResultSetsReturned_02001"],
        ["03000", "sql_statement_not_yet_complete", "SqlStatementNotYetComplete_03000"],
        ["08000", "connection_exception", "ConnectionException_08000"],
        ["08003", "connection_does_not_exist", "ConnectionDoesNotExist_08003"],
        ["08006", "connection_failure", "ConnectionFailure_08006"],
        ["08001", "sqlclient_unable_to_establish_sqlconnection", "SqlclientUnableToEstablishSqlconnection_08001"],
        ["08004", "sqlserver_rejected_establishment_of_sqlconnection", "SqlserverRejectedEstablishmentOfSqlconnection_08004"],
        ["08007", "transaction_resolution_unknown", "TransactionResolutionUnknown_08007"],
        ["08P01", "protocol_violation", "ProtocolViolation_08P01"],
        ["09000", "triggered_action_exception", "TriggeredActionException_09000"],
        ["0A000", "feature_not_supported", "FeatureNotSupported_0A000"],
        ["0B000", "invalid_transaction_initiation", "InvalidTransactionInitiation_0B000"],
        ["0F000", "locator_exception", "LocatorException_0F000"],
        ["0F001", "invalid_locator_specification", "InvalidLocatorSpecification_0F001"],
        ["0L000", "invalid_grantor", "InvalidGrantor_0L000"],
        ["0LP01", "invalid_grant_operation", "InvalidGrantOperation_0LP01"],
        ["0P000", "invalid_role_specification", "InvalidRoleSpecification_0P000"],
        ["0Z000", "diagnostics_exception", "DiagnosticsException_0Z000"],
        ["0Z002", "stacked_diagnostics_accessed_without_active_handler", "StackedDiagnosticsAccessedWithoutActiveHandler_0Z002"],
        ["20000", "case_not_found", "CaseNotFound_20000"],
        ["21000", "cardinality_violation", "CardinalityViolation_21000"],
        ["22000", "data_exception", "DataException_22000"],
        ["2202E", "array_subscript_error", "ArraySubscriptError_2202E"],
        ["22021", "character_not_in_repertoire", "CharacterNotInRepertoire_22021"],
        ["22008", "datetime_field_overflow", "DatetimeFieldOverflow_22008"],
        ["22012", "division_by_zero", "DivisionByZero_22012"],
        ["22005", "error_in_assignment", "ErrorInAssignment_22005"],
        ["2200B", "escape_character_conflict", "EscapeCharacterConflict_2200B"],
        ["22022", "indicator_overflow", "IndicatorOverflow_22022"],
        ["22015", "interval_field_overflow", "IntervalFieldOverflow_22015"],
        ["2201E", "invalid_argument_for_logarithm", "InvalidArgumentForLogarithm_2201E"],
        ["22014", "invalid_argument_for_ntile_function", "InvalidArgumentForNtileFunction_22014"],
        ["22016", "invalid_argument_for_nth_value_function", "InvalidArgumentForNthValueFunction_22016"],
        ["2201F", "invalid_argument_for_power_function", "InvalidArgumentForPowerFunction_2201F"],
        ["2201G", "invalid_argument_for_width_bucket_function", "InvalidArgumentForWidthBucketFunction_2201G"],
        ["22018", "invalid_character_value_for_cast", "InvalidCharacterValueForCast_22018"],
        ["22007", "invalid_datetime_format", "InvalidDatetimeFormat_22007"],
        ["22019", "invalid_escape_character", "InvalidEscapeCharacter_22019"],
        ["2200D", "invalid_escape_octet", "InvalidEscapeOctet_2200D"],
        ["22025", "invalid_escape_sequence", "InvalidEscapeSequence_22025"],
        ["22P06", "nonstandard_use_of_escape_character", "NonstandardUseOfEscapeCharacter_22P06"],
        ["22010", "invalid_indicator_parameter_value", "InvalidIndicatorParameterValue_22010"],
        ["22023", "invalid_parameter_value", "InvalidParameterValue_22023"],
        ["2201B", "invalid_regular_expression", "InvalidRegularExpression_2201B"],
        ["2201W", "invalid_row_count_in_limit_clause", "InvalidRowCountInLimitClause_2201W"],
        ["2201X", "invalid_row_count_in_result_offset_clause", "InvalidRowCountInResultOffsetClause_2201X"],
        ["2202H", "invalid_tablesample_argument", "InvalidTablesampleArgument_2202H"],
        ["2202G", "invalid_tablesample_repeat", "InvalidTablesampleRepeat_2202G"],
        ["22009", "invalid_time_zone_displacement_value", "InvalidTimeZoneDisplacementValue_22009"],
        ["2200C", "invalid_use_of_escape_character", "InvalidUseOfEscapeCharacter_2200C"],
        ["2200G", "most_specific_type_mismatch", "MostSpecificTypeMismatch_2200G"],
        ["22004", "null_value_not_allowed", "NullValueNotAllowed_22004"],
        ["22002", "null_value_no_indicator_parameter", "NullValueNoIndicatorParameter_22002"],
        ["22003", "numeric_value_out_of_range", "NumericValueOutOfRange_22003"],
        ["22026", "string_data_length_mismatch", "StringDataLengthMismatch_22026"],
        ["22001", "string_data_right_truncation", "StringDataRightTruncation_22001"],
        ["22011", "substring_error", "SubstringError_22011"],
        ["22027", "trim_error", "TrimError_22027"],
        ["22024", "unterminated_c_string", "UnterminatedCString_22024"],
        ["2200F", "zero_length_character_string", "ZeroLengthCharacterString_2200F"],
        ["22P01", "floating_point_exception", "FloatingPointException_22P01"],
        ["22P02", "invalid_text_representation", "InvalidTextRepresentation_22P02"],
        ["22P03", "invalid_binary_representation", "InvalidBinaryRepresentation_22P03"],
        ["22P04", "bad_copy_file_format", "BadCopyFileFormat_22P04"],
        ["22P05", "untranslatable_character", "UntranslatableCharacter_22P05"],
        ["2200L", "not_an_xml_document", "NotAnXmlDocument_2200L"],
        ["2200M", "invalid_xml_document", "InvalidXmlDocument_2200M"],
        ["2200N", "invalid_xml_content", "InvalidXmlContent_2200N"],
        ["2200S", "invalid_xml_comment", "InvalidXmlComment_2200S"],
        ["2200T", "invalid_xml_processing_instruction", "InvalidXmlProcessingInstruction_2200T"],
        ["23000", "integrity_constraint_violation", "IntegrityConstraintViolation_23000"],
        ["23001", "restrict_violation", "RestrictViolation_23001"],
        ["23502", "not_null_violation", "NotNullViolation_23502"],
        ["23503", "foreign_key_violation", "ForeignKeyViolation_23503"],
        ["23505", "unique_violation", "UniqueViolation_23505"],
        ["23514", "check_violation", "CheckViolation_23514"],
        ["23P01", "exclusion_violation", "ExclusionViolation_23P01"],
        ["24000", "invalid_cursor_state", "InvalidCursorState_24000"],
        ["25000", "invalid_transaction_state", "InvalidTransactionState_25000"],
        ["25001", "active_sql_transaction", "ActiveSqlTransaction_25001"],
        ["25002", "branch_transaction_already_active", "BranchTransactionAlreadyActive_25002"],
        ["25008", "held_cursor_requires_same_isolation_level", "HeldCursorRequiresSameIsolationLevel_25008"],
        ["25003", "inappropriate_access_mode_for_branch_transaction", "InappropriateAccessModeForBranchTransaction_25003"],
        ["25004", "inappropriate_isolation_level_for_branch_transaction", "InappropriateIsolationLevelForBranchTransaction_25004"],
        ["25005", "no_active_sql_transaction_for_branch_transaction", "NoActiveSqlTransactionForBranchTransaction_25005"],
        ["25006", "read_only_sql_transaction", "ReadOnlySqlTransaction_25006"],
        ["25007", "schema_and_data_statement_mixing_not_supported", "SchemaAndDataStatementMixingNotSupported_25007"],
        ["25P01", "no_active_sql_transaction", "NoActiveSqlTransaction_25P01"],
        ["25P02", "in_failed_sql_transaction", "InFailedSqlTransaction_25P02"],
        ["25P03", "idle_in_transaction_session_timeout", "IdleInTransactionSessionTimeout_25P03"],
        ["26000", "invalid_sql_statement_name", "InvalidSqlStatementName_26000"],
        ["27000", "triggered_data_change_violation", "TriggeredDataChangeViolation_27000"],
        ["28000", "invalid_authorization_specification", "InvalidAuthorizationSpecification_28000"],
        ["28P01", "invalid_password", "InvalidPassword_28P01"],
        ["2B000", "dependent_privilege_descriptors_still_exist", "DependentPrivilegeDescriptorsStillExist_2B000"],
        ["2BP01", "dependent_objects_still_exist", "DependentObjectsStillExist_2BP01"],
        ["2D000", "invalid_transaction_termination", "InvalidTransactionTermination_2D000"],
        ["2F000", "sql_routine_exception", "SqlRoutineException_2F000"],
        ["2F005", "function_executed_no_return_statement", "FunctionExecutedNoReturnStatement_2F005"],
        ["2F002", "modifying_sql_data_not_permitted", "ModifyingSqlDataNotPermitted_2F002"],
        ["2F003", "prohibited_sql_statement_attempted", "ProhibitedSqlStatementAttempted_2F003"],
        ["2F004", "reading_sql_data_not_permitted", "ReadingSqlDataNotPermitted_2F004"],
        ["34000", "invalid_cursor_name", "InvalidCursorName_34000"],
        ["38000", "external_routine_exception", "ExternalRoutineException_38000"],
        ["38001", "containing_sql_not_permitted", "ContainingSqlNotPermitted_38001"],
        ["38002", "modifying_sql_data_not_permitted", "ModifyingSqlDataNotPermitted_38002"],
        ["38003", "prohibited_sql_statement_attempted", "ProhibitedSqlStatementAttempted_38003"],
        ["38004", "reading_sql_data_not_permitted", "ReadingSqlDataNotPermitted_38004"],
        ["39000", "external_routine_invocation_exception", "ExternalRoutineInvocationException_39000"],
        ["39001", "invalid_sqlstate_returned", "InvalidSqlstateReturned_39001"],
        ["39004", "null_value_not_allowed", "NullValueNotAllowed_39004"],
        ["39P01", "trigger_protocol_violated", "TriggerProtocolViolated_39P01"],
        ["39P02", "srf_protocol_violated", "SrfProtocolViolated_39P02"],
        ["39P03", "event_trigger_protocol_violated", "EventTriggerProtocolViolated_39P03"],
        ["3B000", "savepoint_exception", "SavepointException_3B000"],
        ["3B001", "invalid_savepoint_specification", "InvalidSavepointSpecification_3B001"],
        ["3D000", "invalid_catalog_name", "InvalidCatalogName_3D000"],
        ["3F000", "invalid_schema_name", "InvalidSchemaName_3F000"],
        ["40000", "transaction_rollback", "TransactionRollback_40000"],
        ["40002", "transaction_integrity_constraint_violation", "TransactionIntegrityConstraintViolation_40002"],
        ["40001", "serialization_failure", "SerializationFailure_40001"],
        ["40003", "statement_completion_unknown", "StatementCompletionUnknown_40003"],
        ["40P01", "deadlock_detected", "DeadlockDetected_40P01"],
        ["42000", "syntax_error_or_access_rule_violation", "SyntaxErrorOrAccessRuleViolation_42000"],
        ["42601", "syntax_error", "SyntaxError_42601"],
        ["42501", "insufficient_privilege", "InsufficientPrivilege_42501"],
        ["42846", "cannot_coerce", "CannotCoerce_42846"],
        ["42803", "grouping_error", "GroupingError_42803"],
        ["42P20", "windowing_error", "WindowingError_42P20"],
        ["42P19", "invalid_recursion", "InvalidRecursion_42P19"],
        ["42830", "invalid_foreign_key", "InvalidForeignKey_42830"],
        ["42602", "invalid_name", "InvalidName_42602"],
        ["42622", "name_too_long", "NameTooLong_42622"],
        ["42939", "reserved_name", "ReservedName_42939"],
        ["42804", "datatype_mismatch", "DatatypeMismatch_42804"],
        ["42P18", "indeterminate_datatype", "IndeterminateDatatype_42P18"],
        ["42P21", "collation_mismatch", "CollationMismatch_42P21"],
        ["42P22", "indeterminate_collation", "IndeterminateCollation_42P22"],
        ["42809", "wrong_object_type", "WrongObjectType_42809"],
        ["42703", "undefined_column", "UndefinedColumn_42703"],
        ["42883", "undefined_function", "UndefinedFunction_42883"],
        ["42P01", "undefined_table", "UndefinedTable_42P01"],
        ["42P02", "undefined_parameter", "UndefinedParameter_42P02"],
        ["42704", "undefined_object", "UndefinedObject_42704"],
        ["42701", "duplicate_column", "DuplicateColumn_42701"],
        ["42P03", "duplicate_cursor", "DuplicateCursor_42P03"],
        ["42P04", "duplicate_database", "DuplicateDatabase_42P04"],
        ["42723", "duplicate_function", "DuplicateFunction_42723"],
        ["42P05", "duplicate_prepared_statement", "DuplicatePreparedStatement_42P05"],
        ["42P06", "duplicate_schema", "DuplicateSchema_42P06"],
        ["42P07", "duplicate_table", "DuplicateTable_42P07"],
        ["42712", "duplicate_alias", "DuplicateAlias_42712"],
        ["42710", "duplicate_object", "DuplicateObject_42710"],
        ["42702", "ambiguous_column", "AmbiguousColumn_42702"],
        ["42725", "ambiguous_function", "AmbiguousFunction_42725"],
        ["42P08", "ambiguous_parameter", "AmbiguousParameter_42P08"],
        ["42P09", "ambiguous_alias", "AmbiguousAlias_42P09"],
        ["42P10", "invalid_column_reference", "InvalidColumnReference_42P10"],
        ["42611", "invalid_column_definition", "InvalidColumnDefinition_42611"],
        ["42P11", "invalid_cursor_definition", "InvalidCursorDefinition_42P11"],
        ["42P12", "invalid_database_definition", "InvalidDatabaseDefinition_42P12"],
        ["42P13", "invalid_function_definition", "InvalidFunctionDefinition_42P13"],
        ["42P14", "invalid_prepared_statement_definition", "InvalidPreparedStatementDefinition_42P14"],
        ["42P15", "invalid_schema_definition", "InvalidSchemaDefinition_42P15"],
        ["42P16", "invalid_table_definition", "InvalidTableDefinition_42P16"],
        ["42P17", "invalid_object_definition", "InvalidObjectDefinition_42P17"],
        ["44000", "with_check_option_violation", "WithCheckOptionViolation_44000"],
        ["53000", "insufficient_resources", "InsufficientResources_53000"],
        ["53100", "disk_full", "DiskFull_53100"],
        ["53200", "out_of_memory", "OutOfMemory_53200"],
        ["53300", "too_many_connections", "TooManyConnections_53300"],
        ["53400", "configuration_limit_exceeded", "ConfigurationLimitExceeded_53400"],
        ["54000", "program_limit_exceeded", "ProgramLimitExceeded_54000"],
        ["54001", "statement_too_complex", "StatementTooComplex_54001"],
        ["54011", "too_many_columns", "TooManyColumns_54011"],
        ["54023", "too_many_arguments", "TooManyArguments_54023"],
        ["55000", "object_not_in_prerequisite_state", "ObjectNotInPrerequisiteState_55000"],
        ["55006", "object_in_use", "ObjectInUse_55006"],
        ["55P02", "cant_change_runtime_param", "CantChangeRuntimeParam_55P02"],
        ["55P03", "lock_not_available", "LockNotAvailable_55P03"],
        ["57000", "operator_intervention", "OperatorIntervention_57000"],
        ["57014", "query_canceled", "QueryCanceled_57014"],
        ["57P01", "admin_shutdown", "AdminShutdown_57P01"],
        ["57P02", "crash_shutdown", "CrashShutdown_57P02"],
        ["57P03", "cannot_connect_now", "CannotConnectNow_57P03"],
        ["57P04", "database_dropped", "DatabaseDropped_57P04"],
        ["58000", "system_error", "SystemError_58000"],
        ["58030", "io_error", "IoError_58030"],
        ["58P01", "undefined_file", "UndefinedFile_58P01"],
        ["58P02", "duplicate_file", "DuplicateFile_58P02"],
        ["72000", "snapshot_too_old", "SnapshotTooOld_72000"],
        ["F0000", "config_file_error", "ConfigFileError_F0000"],
        ["F0001", "lock_file_exists", "LockFileExists_F0001"],
        ["HV000", "fdw_error", "FdwError_HV000"],
        ["HV005", "fdw_column_name_not_found", "FdwColumnNameNotFound_HV005"],
        ["HV002", "fdw_dynamic_parameter_value_needed", "FdwDynamicParameterValueNeeded_HV002"],
        ["HV010", "fdw_function_sequence_error", "FdwFunctionSequenceError_HV010"],
        ["HV021", "fdw_inconsistent_descriptor_information", "FdwInconsistentDescriptorInformation_HV021"],
        ["HV024", "fdw_invalid_attribute_value", "FdwInvalidAttributeValue_HV024"],
        ["HV007", "fdw_invalid_column_name", "FdwInvalidColumnName_HV007"],
        ["HV008", "fdw_invalid_column_number", "FdwInvalidColumnNumber_HV008"],
        ["HV004", "fdw_invalid_data_type", "FdwInvalidDataType_HV004"],
        ["HV006", "fdw_invalid_data_type_descriptors", "FdwInvalidDataTypeDescriptors_HV006"],
        ["HV091", "fdw_invalid_descriptor_field_identifier", "FdwInvalidDescriptorFieldIdentifier_HV091"],
        ["HV00B", "fdw_invalid_handle", "FdwInvalidHandle_HV00B"],
        ["HV00C", "fdw_invalid_option_index", "FdwInvalidOptionIndex_HV00C"],
        ["HV00D", "fdw_invalid_option_name", "FdwInvalidOptionName_HV00D"],
        ["HV090", "fdw_invalid_string_length_or_buffer_length", "FdwInvalidStringLengthOrBufferLength_HV090"],
        ["HV00A", "fdw_invalid_string_format", "FdwInvalidStringFormat_HV00A"],
        ["HV009", "fdw_invalid_use_of_null_pointer", "FdwInvalidUseOfNullPointer_HV009"],
        ["HV014", "fdw_too_many_handles", "FdwTooManyHandles_HV014"],
        ["HV001", "fdw_out_of_memory", "FdwOutOfMemory_HV001"],
        ["HV00P", "fdw_no_schemas", "FdwNoSchemas_HV00P"],
        ["HV00J", "fdw_option_name_not_found", "FdwOptionNameNotFound_HV00J"],
        ["HV00K", "fdw_reply_handle", "FdwReplyHandle_HV00K"],
        ["HV00Q", "fdw_schema_not_found", "FdwSchemaNotFound_HV00Q"],
        ["HV00R", "fdw_table_not_found", "FdwTableNotFound_HV00R"],
        ["HV00L", "fdw_unable_to_create_execution", "FdwUnableToCreateExecution_HV00L"],
        ["HV00M", "fdw_unable_to_create_reply", "FdwUnableToCreateReply_HV00M"],
        ["HV00N", "fdw_unable_to_establish_connection", "FdwUnableToEstablishConnection_HV00N"],
        ["P0000", "plpgsql_error", "PlpgsqlError_P0000"],
        ["P0001", "raise_exception", "RaiseException_P0001"],
        ["P0002", "no_data_found", "NoDataFound_P0002"],
        ["P0003", "too_many_rows", "TooManyRows_P0003"],
        ["P0004", "assert_failure", "AssertFailure_P0004"],
        ["XX000", "internal_error", "InternalError_XX000"],
        ["XX001", "data_corrupted", "DataCorrupted_XX001"],
        ["XX002", "index_corrupted", "IndexCorrupted_XX002"]
      ].each do |code, _, constant|
        const_set(constant.to_sym, Class.new(PostgresError) do
          @code = code

          def self.===(exception)
            PostgresError.parse(exception)[:code] == @code
          end
        end)

        (@registry ||= {})[code] = const_get(constant.to_sym)
      end
    end

    refine PostgresPR::Connection do
      alias_method :original_query, :query
      def query(*args, &block)
        begin
          original_query(*args, &block)
        rescue DatabaseError => e
          PostgresError.parse(e).yield_self do |parsed|
            raise PostgresError[parsed[:code]].new(parsed[:message])
          end
        end
      end

      # Should call #query but I'm too scared.
      def multi_value_update(table:, column:, pivot:, update_list:, else_value: column)
        <<~SQL
          UPDATE #{table}
          SET #{column} = CASE #{pivot}
          #{update_list.map do |update|
            "  WHEN #{update[:pivot_value].to_sql} THEN #{update[:update_to].to_sql}" <<
            (" -- #{update[:comment]} "unless update[:comment].nil? || update[:comment].empty?)
          end.join($/)}
            #{else_value && "ELSE #{else_value}"}
            END
          WHERE #{pivot} IN (#{update_list.map { |update| update[:pivot_value] }.map(&:to_sql).join(', ')})
        SQL
      end

      # Should call #query but I'm too scared.
      def insert(table:, column_list:, values_list:)
        <<~SQL
          INSERT INTO #{table} (#{column_list.join(', ')}) VALUES
          #{values_list.map { |values| "  (#{values.map(&:to_sql).join(',')})" }.join(",#{$/}")}
        SQL
      end

      def in_transaction
        begin
          query('begin')
          yield
          query('commit')
        rescue InFailedSqlTransaction_25P02
          puts 'transaction aborted'
          query('rollback')
        rescue DatabaseError => e
          query('rollback')
          puts e.message
        end
      end
    end
  end
end
