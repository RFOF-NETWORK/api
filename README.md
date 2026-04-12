# api
InterBOxSpiderWeb.NET PRVPNRFAI.py 2025 - 2029
---
```
/
├── accounts/
│   ├── actions/
│   │   ├── close_account.sql
│   │   ├── create_account.sql
│   │   └── freeze_account.sql
│   ├── events/
│   │   ├── account_closed.sql
│   │   ├── account_created.sql
│   │   └── account_frozen.sql
│   ├── resources/
│   │   ├── account_balances.sql
│   │   ├── account_types.sql
│   │   └── accounts.sql
│   └── schema/
│       ├── openapi.yaml
│       ├── types.sql
│       └── validation.sql
├── clearing/
│   ├── actions/
│   │   ├── add_item.sql
│   │   ├── close_batch.sql
│   │   └── start_batch.sql
│   ├── events/
│   │   ├── batch_closed.sql
│   │   ├── batch_started.sql
│   │   └── item_added.sql
│   ├── resources/
│   │   ├── clearing_batches.sql
│   │   ├── clearing_items.sql
│   │   └── clearing_results.sql
│   └── schema/
│       ├── openapi.yaml
│       ├── types.sql
│       └── validation.sql
├── compliance/
│   ├── actions/
│   │   ├── aml_check.sql (.sql erg.)
│   │   ├── blacklist_check.sql (.sql erg.)
│   │   ├── check_limits.sql (.sql erg.)
│   │   ├── compliance_hold.sql (.sql erg.)
│   │   ├── document_verification.sql (.sql erg.)
│   │   ├── flagging_suspicious.sql (.sql erg.)
│   │   ├── fraud_detection.sql (.sql erg.)
│   │   ├── kyc_verification.sql (.sql erg.)
│   │   ├── pep_screening.sql (.sql erg.)
│   │   ├── regulatory_reporting.sql (.sql erg.)
│   │   ├── risk_assessment.sql (.sql erg.)
│   │   ├── sanction_list_check.sql (.sql erg.)
│   │   ├── tax_compliance_check.sql (.sql erg.)
│   │   ├── transaction_monitoring.sql (.sql erg.)
│   │   ├── verify_identity.sql (.sql erg.)
│   │   ├── whitelist_update.sql (.sql erg.)
│   │   └── audit_log_entry.sql (.sql erg.)
│   ├── events/
│   │   ├── access_revoked.sql (.sql erg.)
│   │   ├── aml_checked.sql (.sql erg.)
│   │   ├── audit_generated.sql (.sql erg.)
│   │   ├── blacklisted.sql (.sql erg.)
│   │   ├── case_closed.sql (.sql erg.)
│   │   ├── case_opened.sql (.sql erg.)
│   │   ├── compliance_updated.sql
│   │   ├── consent_obtained.sql (.sql erg.)
│   │   ├── data_purged.sql (.sql erg.)
│   │   ├── document_approved.sql (.sql erg.)
│   │   ├── escalation_triggered.sql (.sql erg.)
│   │   ├── exemption_granted.sql (.sql erg.)
│   │   ├── flag_raised.sql (.sql erg.)
│   │   ├── fraud_detected.sql (.sql erg.)
│   │   ├── hold_placed.sql (.sql erg.)
│   │   ├── identity_confirmed.sql (.sql erg.)
│   │   ├── kyc_verified.sql (.sql erg.)
│   │   ├── limit_exceeded.sql (.sql erg.)
│   │   ├── log_archived.sql (.sql erg.)
│   │   ├── monitor_alert.sql (.sql erg.)
│   │   ├── pep_identified.sql (.sql erg.)
│   │   ├── policy_violated.sql (.sql erg.)
│   │   ├── report_submitted.sql (.sql erg.)
│   │   ├── review_requested.sql (.sql erg.)
│   │   ├── risk_assessed.sql (.sql erg.)
│   │   ├── sanctions_cleared.sql (.sql erg.)
│   │   ├── status_changed.sql (.sql erg.)
│   │   ├── tax_verified.sql (.sql erg.)
│   │   ├── threshold_reached.sql (.sql erg.)
│   │   ├── update_received.sql (.sql erg.)
│   │   └── whitelisted.sql (.sql erg.)
│   ├── resources/
│   │   ├── compliance_cases.sql
│   │   ├── compliance_rules.sql
│   │   ├── regulatory_codes.sql
│   │   ├── risk_profiles.sql
│   │   └── watchlists.sql
│   └── schema/
│       ├── compliance_update.sql
│       ├── openapi.yaml
│       ├── types.sql
│       ├── validation.sql
│       ├── audit_schema.json (.sql erg.)
│       ├── case_schema.json (.sql erg.)
│       ├── report_config.sql (.sql erg.)
│       ├── risk_models.sql (.sql erg.)
│       └── rule_definitions.sql (.sql erg.)
├── config/
│   ├── actions/
│   │   ├── refresh_config.sql (.sql erg.)
│   │   ├── reset_defaults.sql (.sql erg.)
│   │   └── update_parameter.sql (.sql erg.)
│   ├── events/
│   │   └── parameter_changed.sql (.sql erg.)
│   ├── resources/
│   │   ├── app_settings.sql
│   │   └── environment_vars.sql
│   └── schema/
│       ├── config_constraints.sql
│       ├── openapi.yaml
│       ├── types.sql
│       └── validation.sql
├── docs/
│   ├── actions/
│   │   ├── generate_api_doc.sql (.sql erg.)
│   │   └── update_changelog.sql (.sql erg.)
│   ├── events/
│   │   └── documentation_updated.sql (.sql erg.)
│   ├── resources/
│   │   ├── api_specs.sql
│   │   ├── technical_manual.sql
│   │   └── user_guide.sql
│   └── schema/
│       ├── docs_constraints.sql
│       ├── openapi.yaml
│       ├── types.sql
│       └── validation.sql
├── documents/
│   ├── actions/
│   │   ├── archive_doc.sql (.sql erg.)
│   │   ├── classify_doc.sql (.sql erg.)
│   │   ├── delete_doc.sql (.sql erg.)
│   │   ├── encrypt_doc.sql (.sql erg.)
│   │   ├── index_doc.sql (.sql erg.)
│   │   ├── move_doc.sql (.sql erg.)
│   │   ├── OCR_process.sql (.sql erg.)
│   │   ├── retrieve_doc.sql (.sql erg.)
│   │   ├── sign_doc.sql (.sql erg.)
│   │   ├── tag_doc.sql (.sql erg.)
│   │   ├── upload_doc.sql (.sql erg.)
│   │   ├── version_control.sql (.sql erg.)
│   │   ├── verify_signature.sql (.sql erg.)
│   │   └── watermarking.sql (.sql erg.)
│   ├── events/
│   │   ├── access_denied.sql (.sql erg.)
│   │   ├── access_granted.sql (.sql erg.)
│   │   ├── approval_requested.sql (.sql erg.)
│   │   ├── comment_added.sql (.sql erg.)
│   │   ├── conversion_failed.sql (.sql erg.)
│   │   ├── conversion_started.sql (.sql erg.)
│   │   ├── doc_archived.sql (.sql erg.)
│   │   ├── doc_classified.sql (.sql erg.)
│   │   ├── doc_deleted.sql (.sql erg.)
│   │   ├── doc_downloaded.sql (.sql erg.)
│   │   ├── doc_encrypted.sql (.sql erg.)
│   │   ├── doc_indexed.sql (.sql erg.)
│   │   ├── doc_moved.sql (.sql erg.)
│   │   ├── doc_ocr_completed.sql (.sql erg.)
│   │   ├── doc_retrieved.sql (.sql erg.)
│   │   ├── doc_shared.sql (.sql erg.)
│   │   ├── doc_signed.sql (.sql erg.)
│   │   ├── doc_tagged.sql (.sql erg.)
│   │   ├── doc_uploaded.sql (.sql erg.)
│   │   ├── doc_verified.sql (.sql erg.)
│   │   ├── doc_version_created.sql (.sql erg.)
│   │   ├── doc_watermarked.sql (.sql erg.)
│   │   ├── link_generated.sql (.sql erg.)
│   │   ├── metadata_updated.sql (.sql erg.)
│   │   ├── rejection_noted.sql (.sql erg.)
│   │   └── retention_period_set.sql (.sql erg.)
│   ├── resources/
│   │   ├── document_body.sql
│   │   ├── document_headers.sql
│   │   ├── document_history.sql
│   │   ├── document_links.sql
│   │   ├── document_metadata.sql
│   │   ├── document_permissions.sql
│   │   ├── document_tags.sql
│   │   ├── document_types.sql
│   │   ├── document_versions.sql
│   │   ├── folder_structure.sql
│   │   ├── media_attachments.sql
│   │   ├── signatures.sql
│   │   ├── storage_nodes.sql
│   │   └── templates.sql
│   └── schema/
│       ├── openapi.yaml
│       ├── types.sql
│       └── validation.sql
├── federation/
│   ├── actions/
│   │   ├── cast_vote.sql (.sql erg.)
│   │   ├── join_federation.sql
│   │   ├── leave_federation.sql
│   │   └── propose_vote.sql (.sql erg.)
│   ├── events/
│   │   ├── federation_joined.sql
│   │   ├── federation_left.sql
│   │   ├── proposal_created.sql (.sql erg.)
│   │   └── vote_submitted.sql (.sql erg.)
│   ├── resources/
│   │   ├── federation_members.sql
│   │   ├── governance_rules.sql (.sql erg.)
│   │   └── voting_history.sql (.sql erg.)
│   └── schema/
│       ├── federation_health.sql
│       ├── openapi.yaml
│       ├── types.sql
│       └── validation.sql
├── identity/
│   ├── actions/
│   │   ├── authenticate_user.sql (.sql erg.)
│   │   ├── authorize_service.sql (.sql erg.)
│   │   ├── change_password.sql (.sql erg.)
│   │   ├── create_identity.sql (.sql erg.)
│   │   ├── disable_mfa.sql (.sql erg.)
│   │   ├── enable_mfa.sql (.sql erg.)
│   │   ├── generate_api_key.sql (.sql erg.)
│   │   ├── recover_account.sql (.sql erg.)
│   │   ├── register_device.sql (.sql erg.)
│   │   ├── reset_credentials.sql (.sql erg.)
│   │   ├── revoke_token.sql (.sql erg.)
│   │   ├── update_profile.sql (.sql erg.)
│   │   ├── validate_session.sql (.sql erg.)
│   │   └── verify_email.sql (.sql erg.)
│   ├── events/
│   │   ├── api_key_generated.sql (.sql erg.)
│   │   ├── auth_failed.sql (.sql erg.)
│   │   ├── auth_success.sql (.sql erg.)
│   │   ├── credentials_reset.sql (.sql erg.)
│   │   ├── device_registered.sql (.sql erg.)
│   │   ├── email_verified.sql (.sql erg.)
│   │   ├── identity_created.sql (.sql erg.)
│   │   ├── mfa_disabled.sql (.sql erg.)
│   │   ├── mfa_enabled.sql (.sql erg.)
│   │   ├── password_changed.sql (.sql erg.)
│   │   ├── profile_updated.sql (.sql erg.)
│   │   ├── session_validated.sql (.sql erg.)
│   │   └── token_revoked.sql (.sql erg.)
│   ├── resources/
│   │   ├── api_keys.sql (.sql erg.)
│   │   ├── device_list.sql (.sql erg.)
│   │   ├── identity_profiles.sql (.sql erg.)
│   │   ├── mfa_settings.sql (.sql erg.)
│   │   ├── permissions_map.sql (.sql erg.)
│   │   ├── roles_assignment.sql (.sql erg.)
│   │   ├── session_logs.sql (.sql erg.)
│   │   └── user_credentials.sql (.sql erg.)
│   └── schema/
│       ├── openapi.yaml
│       ├── types.sql
│       └── validation.sql
├── ledger/
│   ├── actions/
│   │   ├── adjust_balance.sql (.sql erg.)
│   │   ├── audit_ledger.sql (.sql erg.)
│   │   ├── close_period.sql (.sql erg.)
│   │   ├── consolidate_accounts.sql (.sql erg.)
│   │   ├── create_entry.sql (.sql erg.)
│   │   ├── freeze_ledger.sql (.sql erg.)
│   │   ├── post_transaction.sql (.sql erg.)
│   │   ├── reconcile_ledger.sql (.sql erg.)
│   │   ├── reverse_entry.sql (.sql erg.)
│   │   ├── transfer_funds.sql (.sql erg.)
│   │   ├── unlock_ledger.sql (.sql erg.)
│   │   ├── update_ledger_metadata.sql (.sql erg.)
│   │   ├── validate_ledger.sql (.sql erg.)
│   │   └── void_transaction.sql (.sql erg.)
│   ├── events/
│   │   ├── balance_adjusted.sql (.sql erg.)
│   │   ├── entry_created.sql (.sql erg.)
│   │   ├── entry_reversed.sql (.sql erg.)
│   │   ├── ledger_audited.sql (.sql erg.)
│   │   ├── ledger_frozen.sql (.sql erg.)
│   │   ├── ledger_reconciled.sql (.sql erg.)
│   │   ├── ledger_unlocked.sql (.sql erg.)
│   │   ├── ledger_validated.sql (.sql erg.)
│   │   ├── period_closed.sql (.sql erg.)
│   │   ├── transaction_posted.sql (.sql erg.)
│   │   └── transaction_voided.sql (.sql erg.)
│   ├── resources/
│   │   ├── audit_trail.sql (.sql erg.)
│   │   ├── chart_of_accounts.sql (.sql erg.)
│   │   ├── journal_entries.sql (.sql erg.)
│   │   ├── ledger_balances.sql (.sql erg.)
│   │   ├── ledger_metadata.sql (.sql erg.)
│   │   ├── period_status.sql (.sql erg.)
│   │   ├── reconciliation_reports.sql (.sql erg.)
│   │   └── transaction_history.sql (.sql erg.)
│   └── schema/
│       ├── openapi.yaml
│       ├── types.sql
│       └── validation.sql
├── liquidity/
│   ├── actions/
│   │   ├── allocate_liquidity.sql (.sql erg.)
│   │   ├── check_liquidity_ratio.sql (.sql erg.)
│   │   ├── deposit_liquidity.sql (.sql erg.)
│   │   ├── forecast_liquidity.sql (.sql erg.)
│   │   ├── manage_collateral.sql (.sql erg.)
│   │   ├── monitor_cash_flow.sql (.sql erg.)
│   │   ├── optimize_liquidity.sql (.sql erg.)
│   │   ├── release_liquidity.sql (.sql erg.)
│   │   ├── set_liquidity_thresholds.sql (.sql erg.)
│   │   ├── simulate_stress_test.sql (.sql erg.)
│   │   ├── transfer_liquidity.sql (.sql erg.)
│   │   └── withdraw_liquidity.sql (.sql erg.)
│   ├── events/
│   │   ├── liquidity_allocated.sql (.sql erg.)
│   │   ├── liquidity_deposited.sql (.sql erg.)
│   │   ├── liquidity_forecasted.sql (.sql erg.)
│   │   ├── liquidity_optimized.sql (.sql erg.)
│   │   ├── liquidity_released.sql (.sql erg.)
│   │   ├── liquidity_threshold_hit.sql (.sql erg.)
│   │   ├── liquidity_transferred.sql (.sql erg.)
│   │   ├── liquidity_withdrawn.sql (.sql erg.)
│   │   ├── stress_test_completed.sql (.sql erg.)
│   │   └── threshold_updated.sql (.sql erg.)
│   ├── resources/
│   │   ├── cash_flow_records.sql (.sql erg.)
│   │   ├── collateral_assets.sql (.sql erg.)
│   │   ├── liquidity_forecasts.sql (.sql erg.)
│   │   ├── liquidity_pools.sql (.sql erg.)
│   │   ├── liquidity_ratios.sql (.sql erg.)
│   │   ├── stress_test_results.sql (.sql erg.)
│   │   └── threshold_configs.sql (.sql erg.)
│   └── schema/
│       ├── openapi.yaml
│       ├── types.sql
│       └── validation.sql
├── scripts/
│   ├── actions/
│   │   ├── backup_system.sql (.sql erg.)
│   │   ├── cleanup_logs.sql (.sql erg.)
│   │   ├── deploy_updates.sql (.sql erg.)
│   │   ├── export_data.sql (.sql erg.)
│   │   ├── import_data.sql (.sql erg.)
│   │   ├── migrate_database.sql (.sql erg.)
│   │   ├── optimize_tables.sql (.sql erg.)
│   │   ├── run_maintenance.sql (.sql erg.)
│   │   ├── schedule_tasks.sql (.sql erg.)
│   │   └── verify_integrity.sql (.sql erg.)
│   ├── events/
│   │   ├── backup_completed.sql (.sql erg.)
│   │   ├── cleanup_finished.sql (.sql erg.)
│   │   ├── deployment_success.sql (.sql erg.)
│   │   ├── export_done.sql (.sql erg.)
│   │   ├── import_failed.sql (.sql erg.)
│   │   ├── migration_started.sql (.sql erg.)
│   │   └── task_scheduled.sql (.sql erg.)
│   ├── resources/
│   │   ├── cron_jobs.sql (.sql erg.)
│   │   ├── maintenance_windows.sql (.sql erg.)
│   │   ├── migration_logs.sql (.sql erg.)
│   │   └── script_configs.sql (.sql erg.)
│   └── schema/
│       ├── openapi.yaml
│       ├── script_constraints.sql
│       ├── types.sql
│       └── validation.sql
├── settlement/
│   ├── actions/
│   │   ├── calculate_netting.sql (.sql erg.)
│   │   ├── confirm_settlement.sql (.sql erg.)
│   │   ├── execute_payout.sql (.sql erg.)
│   │   ├── finalize_settlement.sql (.sql erg.)
│   │   ├── generate_invoice.sql (.sql erg.)
│   │   ├── initiate_settlement.sql (.sql erg.)
│   │   ├── match_trades.sql (.sql erg.)
│   │   ├── process_fees.sql (.sql erg.)
│   │   ├── reconcile_accounts.sql (.sql erg.)
│   │   ├── reject_settlement.sql (.sql erg.)
│   │   ├── retry_failed_settlement.sql (.sql erg.)
│   │   └── update_settlement_status.sql (.sql erg.)
│   ├── events/
│   │   ├── netting_calculated.sql (.sql erg.)
│   │   ├── payout_executed.sql (.sql erg.)
│   │   ├── settlement_confirmed.sql (.sql erg.)
│   │   ├── settlement_finalized.sql (.sql erg.)
│   │   ├── settlement_initiated.sql (.sql erg.)
│   │   ├── settlement_rejected.sql (.sql erg.)
│   │   └── trades_matched.sql (.sql erg.)
│   ├── resources/
│   │   ├── fee_schedules.sql (.sql erg.)
│   │   ├── netting_results.sql (.sql erg.)
│   │   ├── payout_records.sql (.sql erg.)
│   │   ├── settlement_batches.sql (.sql erg.)
│   │   ├── settlement_instructions.sql (.sql erg.)
│   │   └── trade_matches.sql (.sql erg.)
│   └── schema/
│       ├── openapi.yaml
│       ├── types.sql
│       └── validation.sql
├── shared/
│   ├── actions/
│   │   ├── audit_log.sql (.sql erg.)
│   │   ├── encrypt_data.sql (.sql erg.)
│   │   ├── format_response.sql (.sql erg.)
│   │   ├── generate_id.sql (.sql erg.)
│   │   └── log_error.sql (.sql erg.)
│   ├── events/
│   │   ├── error_logged.sql (.sql erg.)
│   │   └── id_generated.sql (.sql erg.)
│   ├── resources/
│   │   ├── common_constants.sql (.sql erg.)
│   │   └── error_codes.sql (.sql erg.)
│   └── schema/
│       ├── openapi.yaml
│       ├── shared_init.sql
│       └── types.sql
├── tests/
│   ├── actions/
│   │   ├── cleanup_test_db.sql (.sql erg.)
│   │   ├── execute_integration_test.sql (.sql erg.)
│   │   ├── execute_unit_test.sql (.sql erg.)
│   │   └── setup_test_env.sql (.sql erg.)
│   ├── events/
│   │   ├── test_failed.sql (.sql erg.)
│   │   └── test_passed.sql (.sql erg.)
│   ├── resources/
│   │   ├── mock_data_sets.sql (.sql erg.)
│   │   └── test_cases.sql (.sql erg.)
│   └── schema/
│       ├── openapi.yaml
│       └── types.sql
├── treasury/
│   ├── actions/
│   │   ├── allocate_funds.sql (.sql erg.)
│   │   ├── check_reserves.sql (.sql erg.)
│   │   ├── execute_fx_trade.sql (.sql erg.)
│   │   ├── hedge_risk.sql (.sql erg.)
│   │   ├── invest_surplus.sql (.sql erg.)
│   │   ├── manage_liquidity.sql (.sql erg.)
│   │   ├── monitor_market_rates.sql (.sql erg.)
│   │   ├── optimize_yield.sql (.sql erg.)
│   │   ├── rebalance_portfolio.sql (.sql erg.)
│   │   └── release_funds.sql (.sql erg.)
│   ├── events/
│   │   ├── funds_allocated.sql (.sql erg.)
│   │   ├── fx_trade_executed.sql (.sql erg.)
│   │   ├── portfolio_rebalanced.sql (.sql erg.)
│   │   ├── reserves_checked.sql (.sql erg.)
│   │   └── risk_hedged.sql (.sql erg.)
│   ├── resources/
│   │   ├── fx_rates.sql (.sql erg.)
│   │   ├── investment_ledger.sql (.sql erg.)
│   │   ├── portfolio_assets.sql (.sql erg.)
│   │   └── reserve_accounts.sql (.sql erg.)
│   └── schema/
│       ├── openapi.yaml
│       ├── treasury_constraints.sql
│       ├── types.sql
│       └── validation.sql
├── .env
├── .gitignore
├── docker-compose.yml
├── Dockerfile
├── LICENSE
├── Makefile
├── package.json
├── README.md
└── server.sql (.sql erg.)
```
