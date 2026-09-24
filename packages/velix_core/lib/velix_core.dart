library velix_core;

export 'config/environment.dart';
export 'config/supabase_config.dart';

export 'constants/app_colors.dart';
export 'constants/app_text_styles.dart';
export 'constants/car_images.dart';
export 'theme/app_theme.dart';
export 'localization/app_localization.dart';
export 'storage/secure_storage_service.dart';
export 'network/api_client.dart';

// Models
export 'models/user_model.dart';
export 'models/car_model.dart';
export 'models/booking_model.dart';
export 'models/payment_model.dart';
export 'models/notification_model.dart';
export 'models/chat_model.dart';
export 'models/support_ticket_model.dart';
export 'models/dispute_model.dart';

// Services
export 'services/pricing_service.dart';
export 'services/file_upload_service.dart';
export 'services/realtime_service.dart';

// Data Sources & Repositories
export 'data_sources/remote/auth_remote_data_source.dart';
export 'data_sources/remote/vehicle_remote_data_source.dart';
export 'data_sources/remote/booking_remote_data_source.dart';
export 'data_sources/remote/payment_remote_data_source.dart';
export 'data_sources/remote/support_remote_data_source.dart';
export 'repositories/auth_repository.dart';
export 'repositories/vehicle_repository.dart';
export 'repositories/booking_repository.dart';
export 'repositories/fleet_repository.dart';
export 'repositories/payment_repository.dart';
export 'repositories/support_repository.dart';

// Shared Components
export 'shared_components/buttons/primary_button.dart';
export 'shared_components/buttons/partner_orange_button.dart';
export 'shared_components/buttons/velix_back_button.dart';
export 'shared_components/headers/velix_app_header.dart';
export 'shared_components/feedback/velix_toast.dart';
export 'shared_components/display/velix_logo_header.dart';
export 'shared_components/inputs/app_text_field.dart';
export 'shared_components/inputs/otp_pin_input.dart';
export 'shared_components/inputs/country_code_picker.dart';
export 'shared_components/cards/car_card.dart';
export 'shared_components/navigation/app_bottom_nav_bar.dart';
export 'shared_components/states/loading_skeleton.dart';
export 'shared_components/states/empty_state_view.dart';
export 'services/biometric_auth_service.dart';
export 'shared_components/modals/social_auth_modal.dart';
export 'shared_components/modals/image_picker_modal.dart';
export 'shared_components/modals/auth_gate_modal.dart';
export 'shared_components/modals/legal_terms_modal.dart';
