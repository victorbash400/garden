/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _ida;
import 'dart:typed_data' as _idt;
import 'package:garden_client/src/protocol/files/content_download.dart'
    as _ic1eq1qp;
import 'package:garden_client/src/protocol/files/directory_listing.dart'
    as _i6024znp;
import 'package:garden_client/src/protocol/files/drive_event.dart' as _ib0wfils;
import 'package:garden_client/src/protocol/files/file_comment.dart'
    as _i6rexlqc;
import 'package:garden_client/src/protocol/files/file_lease.dart' as _iiqvbxq9;
import 'package:garden_client/src/protocol/files/file_node.dart' as _i2qlj4hx;
import 'package:garden_client/src/protocol/files/file_version.dart'
    as _ibt6e7l6;
import 'package:garden_client/src/protocol/files/filesystem_request.dart'
    as _igspcefl;
import 'package:garden_client/src/protocol/files/node_kind.dart' as _igh51ulr;
import 'package:garden_client/src/protocol/files/uploaded_part.dart'
    as _ieod4w9g;
import 'package:garden_client/src/protocol/gardens/account_details.dart'
    as _i7n7hin1;
import 'package:garden_client/src/protocol/gardens/finder_session.dart'
    as _ihw30tky;
import 'package:garden_client/src/protocol/gardens/garden_summary.dart'
    as _iwcj6pye;
import 'package:garden_client/src/protocol/greetings/greeting.dart'
    as _iz66whiu;
import 'package:http/http.dart' as _i85jenna;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'protocol.dart' as _il2as5qe;

/// By extending [EmailIdpBaseEndpoint], the email identity provider endpoints
/// are made available on the server and enable the corresponding sign-in widget
/// on the client.
/// {@category Endpoint}
class EndpointEmailIdp extends _iaic.EndpointEmailIdpBase {
  EndpointEmailIdp(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'emailIdp';

  /// Logs in the user and returns a new session.
  ///
  /// Throws an [EmailAccountLoginException] in case of errors, with reason:
  /// - [EmailAccountLoginExceptionReason.invalidCredentials] if the email or
  ///   password is incorrect.
  /// - [EmailAccountLoginExceptionReason.tooManyAttempts] if there have been
  ///   too many failed login attempts.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _ida.Future<_iacc.AuthSuccess> login({
    required String email,
    required String password,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'emailIdp',
    'login',
    {
      'email': email,
      'password': password,
    },
  );

  /// Starts the registration for a new user account with an email-based login
  /// associated to it.
  ///
  /// Upon successful completion of this method, an email will have been
  /// sent to [email] with a verification link, which the user must open to
  /// complete the registration.
  ///
  /// Always returns a account request ID, which can be used to complete the
  /// registration. If the email is already registered, the returned ID will not
  /// be valid.
  @override
  _ida.Future<_isc.UuidValue> startRegistration({required String email}) =>
      caller.callServerEndpoint<_isc.UuidValue>(
        'emailIdp',
        'startRegistration',
        {'email': email},
      );

  /// Verifies an account request code and returns a token
  /// that can be used to complete the account creation.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if no request exists
  ///   for the given [accountRequestId] or [verificationCode] is invalid.
  @override
  _ida.Future<String> verifyRegistrationCode({
    required _isc.UuidValue accountRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyRegistrationCode',
    {
      'accountRequestId': accountRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a new account registration, creating a new auth user with a
  /// profile and attaching the given email account to it.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if the [registrationToken]
  ///   is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  ///
  /// Returns a session for the newly created user.
  @override
  _ida.Future<_iacc.AuthSuccess> finishRegistration({
    required String registrationToken,
    required String password,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'emailIdp',
    'finishRegistration',
    {
      'registrationToken': registrationToken,
      'password': password,
    },
  );

  /// Requests a password reset for [email].
  ///
  /// If the email address is registered, an email with reset instructions will
  /// be send out. If the email is unknown, this method will have no effect.
  ///
  /// Always returns a password reset request ID, which can be used to complete
  /// the reset. If the email is not registered, the returned ID will not be
  /// valid.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to request a password reset.
  ///
  @override
  _ida.Future<_isc.UuidValue> startPasswordReset({required String email}) =>
      caller.callServerEndpoint<_isc.UuidValue>(
        'emailIdp',
        'startPasswordReset',
        {'email': email},
      );

  /// Verifies a password reset code and returns a finishPasswordResetToken
  /// that can be used to finish the password reset.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to verify the password reset.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// If multiple steps are required to complete the password reset, this endpoint
  /// should be overridden to return credentials for the next step instead
  /// of the credentials for setting the password.
  @override
  _ida.Future<String> verifyPasswordResetCode({
    required _isc.UuidValue passwordResetRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyPasswordResetCode',
    {
      'passwordResetRequestId': passwordResetRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a password reset request by setting a new password.
  ///
  /// The [verificationCode] returned from [verifyPasswordResetCode] is used to
  /// validate the password reset request.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.policyViolation] if the new
  ///   password does not comply with the password policy.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _ida.Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required String newPassword,
  }) => caller.callServerEndpoint<void>(
    'emailIdp',
    'finishPasswordReset',
    {
      'finishPasswordResetToken': finishPasswordResetToken,
      'newPassword': newPassword,
    },
  );

  @override
  _ida.Future<bool> hasAccount() => caller.callServerEndpoint<bool>(
    'emailIdp',
    'hasAccount',
    {},
  );
}

/// By extending [RefreshJwtTokensEndpoint], the JWT token refresh endpoint
/// is made available on the server and enables automatic token refresh on the client.
/// {@category Endpoint}
class EndpointJwtRefresh extends _iacc.EndpointRefreshJwtTokens {
  EndpointJwtRefresh(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'jwtRefresh';

  /// Creates a new token pair for the given [refreshToken].
  ///
  /// If [refreshToken] is omitted, cookie-mode web clients fall back to the
  /// configured HttpOnly refresh cookie. When neither source is present this
  /// throws [RefreshTokenNotFoundException], the same public "no usable refresh
  /// credential" exception used for unknown refresh tokens.
  ///
  /// Can throw the following exceptions:
  /// -[RefreshTokenMalformedException]: refresh token is malformed and could
  ///   not be parsed. Not expected to happen for tokens issued by the server.
  /// -[RefreshTokenNotFoundException]: refresh token is unknown to the server.
  ///   Either the token was deleted or generated by a different server.
  /// -[RefreshTokenExpiredException]: refresh token has expired. Will happen
  ///   only if it has not been used within configured `refreshTokenLifetime`.
  /// -[RefreshTokenInvalidSecretException]: refresh token is incorrect, meaning
  ///   it does not refer to the current secret refresh token. This indicates
  ///   either a malfunctioning client or a malicious attempt by someone who has
  ///   obtained the refresh token. In this case the underlying refresh token
  ///   will be deleted, and access to it will expire fully when the last access
  ///   token is elapsed.
  ///
  /// This endpoint is unauthenticated, meaning the client won't include any
  /// authentication information with the call.
  @override
  _ida.Future<_iacc.AuthSuccess> refreshAccessToken({String? refreshToken}) =>
      caller.callServerEndpoint<_iacc.AuthSuccess>(
        'jwtRefresh',
        'refreshAccessToken',
        {'refreshToken': refreshToken},
        authenticated: false,
      );
}

/// {@category Endpoint}
class EndpointPasskeyIdp extends _iaic.EndpointPasskeyIdpBase {
  EndpointPasskeyIdp(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'passkeyIdp';

  @override
  _ida.Future<void> register({
    required _iaic.PasskeyRegistrationRequest registrationRequest,
  }) => caller.callServerEndpoint<void>(
    'passkeyIdp',
    'register',
    {'registrationRequest': registrationRequest},
  );

  @override
  _ida.Future<_iacc.AuthSuccess> login({
    required _iaic.PasskeyLoginRequest loginRequest,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'passkeyIdp',
    'login',
    {'loginRequest': loginRequest},
  );

  _ida.Future<
    List<({DateTime createdAt, _isc.UuidValue id, _idt.ByteData keyId})>
  >
  listKeys() =>
      caller.callServerEndpoint<
        List<({DateTime createdAt, _isc.UuidValue id, _idt.ByteData keyId})>
      >(
        'passkeyIdp',
        'listKeys',
        {},
      );

  _ida.Future<void> removeKey(_isc.UuidValue id) =>
      caller.callServerEndpoint<void>(
        'passkeyIdp',
        'removeKey',
        {'id': id},
      );

  /// Returns a new challenge to be used for a login or registration request.
  @override
  _ida.Future<({_idt.ByteData challenge, _isc.UuidValue id})>
  createChallenge() =>
      caller.callServerEndpoint<({_idt.ByteData challenge, _isc.UuidValue id})>(
        'passkeyIdp',
        'createChallenge',
        {},
      );

  @override
  _ida.Future<bool> hasAccount() => caller.callServerEndpoint<bool>(
    'passkeyIdp',
    'hasAccount',
    {},
  );
}

/// {@category Endpoint}
class EndpointCollaboration extends _isc.EndpointRef {
  EndpointCollaboration(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'collaboration';

  _ida.Future<List<_i6rexlqc.FileComment>> comments(int nodeId) =>
      caller.callServerEndpoint<List<_i6rexlqc.FileComment>>(
        'collaboration',
        'comments',
        {'nodeId': nodeId},
      );

  _ida.Future<_i6rexlqc.FileComment> comment(
    int nodeId,
    String text,
  ) => caller.callServerEndpoint<_i6rexlqc.FileComment>(
    'collaboration',
    'comment',
    {
      'nodeId': nodeId,
      'text': text,
    },
  );

  _ida.Future<_iiqvbxq9.FileLease> acquire(int nodeId) =>
      caller.callServerEndpoint<_iiqvbxq9.FileLease>(
        'collaboration',
        'acquire',
        {'nodeId': nodeId},
      );

  _ida.Future<void> release(
    int nodeId,
    String token,
  ) => caller.callServerEndpoint<void>(
    'collaboration',
    'release',
    {
      'nodeId': nodeId,
      'token': token,
    },
  );
}

/// {@category Endpoint}
class EndpointContent extends _isc.EndpointRef {
  EndpointContent(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'content';

  _ida.Future<_ibt6e7l6.FileVersion> beginEdit(
    int nodeId,
    int baseVersion,
    int size,
    _isc.UuidValue operationId, {
    DateTime? modifiedAt,
  }) => caller.callServerEndpoint<_ibt6e7l6.FileVersion>(
    'content',
    'beginEdit',
    {
      'nodeId': nodeId,
      'baseVersion': baseVersion,
      'size': size,
      'operationId': operationId,
      'modifiedAt': modifiedAt,
    },
  );

  _ida.Future<_ibt6e7l6.FileVersion> begin(
    int nodeId,
    int baseVersion,
    int size,
  ) => caller.callServerEndpoint<_ibt6e7l6.FileVersion>(
    'content',
    'begin',
    {
      'nodeId': nodeId,
      'baseVersion': baseVersion,
      'size': size,
    },
  );

  _ida.Future<_ibt6e7l6.FileVersion> beginMultipart(
    int nodeId,
    int baseVersion,
    int size,
  ) => caller.callServerEndpoint<_ibt6e7l6.FileVersion>(
    'content',
    'beginMultipart',
    {
      'nodeId': nodeId,
      'baseVersion': baseVersion,
      'size': size,
    },
  );

  _ida.Future<List<String>> uploadParts(
    int versionId,
    int first,
    int count,
  ) => caller.callServerEndpoint<List<String>>(
    'content',
    'uploadParts',
    {
      'versionId': versionId,
      'first': first,
      'count': count,
    },
  );

  _ida.Future<void> copyParts(
    int versionId,
    int first,
    int count,
  ) => caller.callServerEndpoint<void>(
    'content',
    'copyParts',
    {
      'versionId': versionId,
      'first': first,
      'count': count,
    },
  );

  _ida.Future<List<_ieod4w9g.UploadedPart>> uploadedParts(int versionId) =>
      caller.callServerEndpoint<List<_ieod4w9g.UploadedPart>>(
        'content',
        'uploadedParts',
        {'versionId': versionId},
      );

  _ida.Future<_ic1eq1qp.ContentDownload> download(
    int nodeId,
    int versionId,
  ) => caller.callServerEndpoint<_ic1eq1qp.ContentDownload>(
    'content',
    'download',
    {
      'nodeId': nodeId,
      'versionId': versionId,
    },
  );

  _ida.Future<void> writeChunk(
    int versionId,
    int index,
    _idt.ByteData data,
  ) => caller.callServerEndpoint<void>(
    'content',
    'writeChunk',
    {
      'versionId': versionId,
      'index': index,
      'data': data,
    },
  );

  _ida.Future<_i2qlj4hx.FileNode> finish(int versionId) =>
      caller.callServerEndpoint<_i2qlj4hx.FileNode>(
        'content',
        'finish',
        {'versionId': versionId},
      );

  _ida.Future<_idt.ByteData> read(
    int nodeId,
    int versionId,
    int offset,
    int length,
  ) => caller.callServerEndpoint<_idt.ByteData>(
    'content',
    'read',
    {
      'nodeId': nodeId,
      'versionId': versionId,
      'offset': offset,
      'length': length,
    },
  );

  _ida.Future<List<_ibt6e7l6.FileVersion>> versions(int nodeId) =>
      caller.callServerEndpoint<List<_ibt6e7l6.FileVersion>>(
        'content',
        'versions',
        {'nodeId': nodeId},
      );
}

/// {@category Endpoint}
class EndpointFiles extends _isc.EndpointRef {
  EndpointFiles(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'files';

  _ida.Future<_i2qlj4hx.FileNode> get(int nodeId) =>
      caller.callServerEndpoint<_i2qlj4hx.FileNode>(
        'files',
        'get',
        {'nodeId': nodeId},
      );

  _ida.Future<List<_ib0wfils.DriveEvent>> changes(
    int gardenId,
    int afterRevision,
  ) => caller.callServerEndpoint<List<_ib0wfils.DriveEvent>>(
    'files',
    'changes',
    {
      'gardenId': gardenId,
      'afterRevision': afterRevision,
    },
  );

  _ida.Future<List<_i2qlj4hx.FileNode>> snapshot(
    int gardenId,
    int afterNodeId,
  ) => caller.callServerEndpoint<List<_i2qlj4hx.FileNode>>(
    'files',
    'snapshot',
    {
      'gardenId': gardenId,
      'afterNodeId': afterNodeId,
    },
  );

  _ida.Future<int> revision(int gardenId) => caller.callServerEndpoint<int>(
    'files',
    'revision',
    {'gardenId': gardenId},
  );

  _ida.Future<List<_i2qlj4hx.FileNode>> listPage(
    int gardenId,
    int parentId,
    int afterNodeId,
  ) => caller.callServerEndpoint<List<_i2qlj4hx.FileNode>>(
    'files',
    'listPage',
    {
      'gardenId': gardenId,
      'parentId': parentId,
      'afterNodeId': afterNodeId,
    },
  );

  _ida.Future<_i6024znp.DirectoryListing> list(
    int gardenId,
    int parentId,
  ) => caller.callServerEndpoint<_i6024znp.DirectoryListing>(
    'files',
    'list',
    {
      'gardenId': gardenId,
      'parentId': parentId,
    },
  );

  _ida.Future<_i2qlj4hx.FileNode> create(
    int gardenId,
    int parentId,
    String name,
    _igh51ulr.NodeKind kind,
  ) => caller.callServerEndpoint<_i2qlj4hx.FileNode>(
    'files',
    'create',
    {
      'gardenId': gardenId,
      'parentId': parentId,
      'name': name,
      'kind': kind,
    },
  );

  _ida.Future<_i2qlj4hx.FileNode> move(
    int nodeId,
    int parentId,
    String name,
  ) => caller.callServerEndpoint<_i2qlj4hx.FileNode>(
    'files',
    'move',
    {
      'nodeId': nodeId,
      'parentId': parentId,
      'name': name,
    },
  );

  _ida.Future<void> delete(int nodeId) => caller.callServerEndpoint<void>(
    'files',
    'delete',
    {'nodeId': nodeId},
  );

  _ida.Stream<_ib0wfils.DriveEvent> watch(
    int gardenId,
    int afterRevision,
  ) =>
      caller.callStreamingServerEndpoint<
        _ida.Stream<_ib0wfils.DriveEvent>,
        _ib0wfils.DriveEvent
      >(
        'files',
        'watch',
        {
          'gardenId': gardenId,
          'afterRevision': afterRevision,
        },
        {},
      );
}

/// {@category Endpoint}
class EndpointFilesystem extends _isc.EndpointRef {
  EndpointFilesystem(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'filesystem';

  _ida.Future<List<_ib0wfils.DriveEvent>> mutate(
    int gardenId,
    _igspcefl.FilesystemRequest request,
  ) => caller.callServerEndpoint<List<_ib0wfils.DriveEvent>>(
    'filesystem',
    'mutate',
    {
      'gardenId': gardenId,
      'request': request,
    },
  );
}

/// {@category Endpoint}
class EndpointGarden extends _isc.EndpointRef {
  EndpointGarden(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'garden';

  _ida.Future<_i7n7hin1.AccountDetails> account() =>
      caller.callServerEndpoint<_i7n7hin1.AccountDetails>(
        'garden',
        'account',
        {},
      );

  _ida.Future<_ihw30tky.FinderSession> finderSession(int gardenId) =>
      caller.callServerEndpoint<_ihw30tky.FinderSession>(
        'garden',
        'finderSession',
        {'gardenId': gardenId},
      );

  _ida.Future<void> revokeFinderSessions(List<String> tokenIds) =>
      caller.callServerEndpoint<void>(
        'garden',
        'revokeFinderSessions',
        {'tokenIds': tokenIds},
      );

  _ida.Future<List<_iwcj6pye.GardenSummary>> list() =>
      caller.callServerEndpoint<List<_iwcj6pye.GardenSummary>>(
        'garden',
        'list',
        {},
      );

  _ida.Future<_iwcj6pye.GardenSummary> create(String name) =>
      caller.callServerEndpoint<_iwcj6pye.GardenSummary>(
        'garden',
        'create',
        {'name': name},
      );

  _ida.Future<String> invite(int gardenId) => caller.callServerEndpoint<String>(
    'garden',
    'invite',
    {'gardenId': gardenId},
  );

  _ida.Future<_iwcj6pye.GardenSummary> join(String invitationCode) =>
      caller.callServerEndpoint<_iwcj6pye.GardenSummary>(
        'garden',
        'join',
        {'invitationCode': invitationCode},
      );

  _ida.Future<_iwcj6pye.GardenSummary> connect(int gardenId) =>
      caller.callServerEndpoint<_iwcj6pye.GardenSummary>(
        'garden',
        'connect',
        {'gardenId': gardenId},
      );

  _ida.Future<void> delete(int gardenId) => caller.callServerEndpoint<void>(
    'garden',
    'delete',
    {'gardenId': gardenId},
  );
}

/// This is an example endpoint that returns a greeting message through
/// its [hello] method.
/// {@category Endpoint}
class EndpointGreeting extends _isc.EndpointRef {
  EndpointGreeting(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'greeting';

  /// Returns a personalized greeting message: "Hello {name}".
  _ida.Future<_iz66whiu.Greeting> hello(String name) =>
      caller.callServerEndpoint<_iz66whiu.Greeting>(
        'greeting',
        'hello',
        {'name': name},
      );
}

class Modules {
  Modules(Client client) {
    serverpod_auth_idp = _iaic.Caller(client);
    serverpod_auth_core = _iacc.Caller(client);
  }

  late final _iaic.Caller serverpod_auth_idp;

  late final _iacc.Caller serverpod_auth_core;
}

class Client extends _isc.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _isc.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_isc.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
    _i85jenna.Client? httpClientOverride,
  }) : super(
         host,
         _il2as5qe.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
         httpClientOverride: httpClientOverride,
       ) {
    emailIdp = EndpointEmailIdp(this);
    jwtRefresh = EndpointJwtRefresh(this);
    passkeyIdp = EndpointPasskeyIdp(this);
    collaboration = EndpointCollaboration(this);
    content = EndpointContent(this);
    files = EndpointFiles(this);
    filesystem = EndpointFilesystem(this);
    garden = EndpointGarden(this);
    greeting = EndpointGreeting(this);
    modules = Modules(this);
  }

  late final EndpointEmailIdp emailIdp;

  late final EndpointJwtRefresh jwtRefresh;

  late final EndpointPasskeyIdp passkeyIdp;

  late final EndpointCollaboration collaboration;

  late final EndpointContent content;

  late final EndpointFiles files;

  late final EndpointFilesystem filesystem;

  late final EndpointGarden garden;

  late final EndpointGreeting greeting;

  late final Modules modules;

  @override
  Map<String, _isc.EndpointRef> get endpointRefLookup => {
    'emailIdp': emailIdp,
    'jwtRefresh': jwtRefresh,
    'passkeyIdp': passkeyIdp,
    'collaboration': collaboration,
    'content': content,
    'files': files,
    'filesystem': filesystem,
    'garden': garden,
    'greeting': greeting,
  };

  @override
  Map<String, _isc.ModuleEndpointCaller> get moduleLookup => {
    'serverpod_auth_idp': modules.serverpod_auth_idp,
    'serverpod_auth_core': modules.serverpod_auth_core,
  };
}
