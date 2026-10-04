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
import 'dart:typed_data' as _idt;
import 'package:garden_server/src/generated/files/filesystem_request.dart'
    as _ia306jky;
import 'package:garden_server/src/generated/files/node_kind.dart' as _iso8aj7z;
import 'package:garden_server/src/generated/future_calls.dart' as _id1va6nu;
import 'package:garden_server/src/generated/protocol.dart' as _ipujdd36;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import '../auth/email_idp_endpoint.dart' as _iuc1hd5t;
import '../auth/jwt_refresh_endpoint.dart' as _inwq3ztq;
import '../auth/passkey_idp_endpoint.dart' as _ia8doutj;
import '../files/collaboration_endpoint.dart' as _iiks30z9;
import '../files/content_endpoint.dart' as _iqqtuyco;
import '../files/files_endpoint.dart' as _idx8vriz;
import '../files/filesystem_endpoint.dart' as _im12bomv;
import '../gardens/garden_endpoint.dart' as _isd11de7;
import '../greetings/greeting_endpoint.dart' as _il624ik7;
export 'future_calls.dart' show ServerpodFutureCallsGetter;

class Endpoints extends _is.EndpointDispatch {
  @override
  void initializeEndpoints(_is.Server server) {
    var endpoints = <String, _is.Endpoint>{
      'emailIdp': _iuc1hd5t.EmailIdpEndpoint()
        ..initialize(
          server,
          'emailIdp',
          null,
        ),
      'jwtRefresh': _inwq3ztq.JwtRefreshEndpoint()
        ..initialize(
          server,
          'jwtRefresh',
          null,
        ),
      'passkeyIdp': _ia8doutj.PasskeyIdpEndpoint()
        ..initialize(
          server,
          'passkeyIdp',
          null,
        ),
      'collaboration': _iiks30z9.CollaborationEndpoint()
        ..initialize(
          server,
          'collaboration',
          null,
        ),
      'content': _iqqtuyco.ContentEndpoint()
        ..initialize(
          server,
          'content',
          null,
        ),
      'files': _idx8vriz.FilesEndpoint()
        ..initialize(
          server,
          'files',
          null,
        ),
      'filesystem': _im12bomv.FilesystemEndpoint()
        ..initialize(
          server,
          'filesystem',
          null,
        ),
      'garden': _isd11de7.GardenEndpoint()
        ..initialize(
          server,
          'garden',
          null,
        ),
      'greeting': _il624ik7.GreetingEndpoint()
        ..initialize(
          server,
          'greeting',
          null,
        ),
    };
    connectors['emailIdp'] = _is.EndpointConnector(
      name: 'emailIdp',
      endpoint: endpoints['emailIdp']!,
      methodConnectors: {
        'login': _is.MethodConnector(
          name: 'login',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'password': _is.ParameterDescription(
              name: 'password',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint).login(
                    session,
                    email: params['email'],
                    password: params['password'],
                  ),
        ),
        'startRegistration': _is.MethodConnector(
          name: 'startRegistration',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .startRegistration(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyRegistrationCode': _is.MethodConnector(
          name: 'verifyRegistrationCode',
          params: {
            'accountRequestId': _is.ParameterDescription(
              name: 'accountRequestId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _is.ParameterDescription(
              name: 'verificationCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .verifyRegistrationCode(
                    session,
                    accountRequestId: params['accountRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishRegistration': _is.MethodConnector(
          name: 'finishRegistration',
          params: {
            'registrationToken': _is.ParameterDescription(
              name: 'registrationToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'password': _is.ParameterDescription(
              name: 'password',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .finishRegistration(
                    session,
                    registrationToken: params['registrationToken'],
                    password: params['password'],
                  ),
        ),
        'startPasswordReset': _is.MethodConnector(
          name: 'startPasswordReset',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .startPasswordReset(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyPasswordResetCode': _is.MethodConnector(
          name: 'verifyPasswordResetCode',
          params: {
            'passwordResetRequestId': _is.ParameterDescription(
              name: 'passwordResetRequestId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _is.ParameterDescription(
              name: 'verificationCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .verifyPasswordResetCode(
                    session,
                    passwordResetRequestId: params['passwordResetRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishPasswordReset': _is.MethodConnector(
          name: 'finishPasswordReset',
          params: {
            'finishPasswordResetToken': _is.ParameterDescription(
              name: 'finishPasswordResetToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'newPassword': _is.ParameterDescription(
              name: 'newPassword',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .finishPasswordReset(
                    session,
                    finishPasswordResetToken:
                        params['finishPasswordResetToken'],
                    newPassword: params['newPassword'],
                  ),
        ),
        'hasAccount': _is.MethodConnector(
          name: 'hasAccount',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .hasAccount(session),
        ),
      },
    );
    connectors['jwtRefresh'] = _is.EndpointConnector(
      name: 'jwtRefresh',
      endpoint: endpoints['jwtRefresh']!,
      methodConnectors: {
        'refreshAccessToken': _is.MethodConnector(
          name: 'refreshAccessToken',
          params: {
            'refreshToken': _is.ParameterDescription(
              name: 'refreshToken',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['jwtRefresh'] as _inwq3ztq.JwtRefreshEndpoint)
                      .refreshAccessToken(
                        session,
                        refreshToken: params['refreshToken'],
                      ),
        ),
      },
    );
    connectors['passkeyIdp'] = _is.EndpointConnector(
      name: 'passkeyIdp',
      endpoint: endpoints['passkeyIdp']!,
      methodConnectors: {
        'register': _is.MethodConnector(
          name: 'register',
          params: {
            'registrationRequest': _is.ParameterDescription(
              name: 'registrationRequest',
              type: _is.getType<_iais.PasskeyRegistrationRequest>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['passkeyIdp'] as _ia8doutj.PasskeyIdpEndpoint)
                      .register(
                        session,
                        registrationRequest: params['registrationRequest'],
                      ),
        ),
        'login': _is.MethodConnector(
          name: 'login',
          params: {
            'loginRequest': _is.ParameterDescription(
              name: 'loginRequest',
              type: _is.getType<_iais.PasskeyLoginRequest>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['passkeyIdp'] as _ia8doutj.PasskeyIdpEndpoint)
                      .login(
                        session,
                        loginRequest: params['loginRequest'],
                      ),
        ),
        'listKeys': _is.MethodConnector(
          name: 'listKeys',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['passkeyIdp'] as _ia8doutj.PasskeyIdpEndpoint)
                      .listKeys(session)
                      .then(
                        (container) =>
                            _ipujdd36.Protocol().mapContainerToJson(container),
                      ),
        ),
        'removeKey': _is.MethodConnector(
          name: 'removeKey',
          params: {
            'id': _is.ParameterDescription(
              name: 'id',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['passkeyIdp'] as _ia8doutj.PasskeyIdpEndpoint)
                      .removeKey(
                        session,
                        params['id'],
                      ),
        ),
        'createChallenge': _is.MethodConnector(
          name: 'createChallenge',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['passkeyIdp'] as _ia8doutj.PasskeyIdpEndpoint)
                      .createChallenge(session)
                      .then(
                        (record) =>
                            _ipujdd36.Protocol().mapRecordToJson(record),
                      ),
        ),
        'hasAccount': _is.MethodConnector(
          name: 'hasAccount',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['passkeyIdp'] as _ia8doutj.PasskeyIdpEndpoint)
                      .hasAccount(session),
        ),
      },
    );
    connectors['collaboration'] = _is.EndpointConnector(
      name: 'collaboration',
      endpoint: endpoints['collaboration']!,
      methodConnectors: {
        'comments': _is.MethodConnector(
          name: 'comments',
          params: {
            'nodeId': _is.ParameterDescription(
              name: 'nodeId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['collaboration']
                          as _iiks30z9.CollaborationEndpoint)
                      .comments(
                        session,
                        params['nodeId'],
                      ),
        ),
        'comment': _is.MethodConnector(
          name: 'comment',
          params: {
            'nodeId': _is.ParameterDescription(
              name: 'nodeId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'text': _is.ParameterDescription(
              name: 'text',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['collaboration']
                          as _iiks30z9.CollaborationEndpoint)
                      .comment(
                        session,
                        params['nodeId'],
                        params['text'],
                      ),
        ),
        'acquire': _is.MethodConnector(
          name: 'acquire',
          params: {
            'nodeId': _is.ParameterDescription(
              name: 'nodeId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['collaboration']
                          as _iiks30z9.CollaborationEndpoint)
                      .acquire(
                        session,
                        params['nodeId'],
                      ),
        ),
        'release': _is.MethodConnector(
          name: 'release',
          params: {
            'nodeId': _is.ParameterDescription(
              name: 'nodeId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'token': _is.ParameterDescription(
              name: 'token',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['collaboration']
                          as _iiks30z9.CollaborationEndpoint)
                      .release(
                        session,
                        params['nodeId'],
                        params['token'],
                      ),
        ),
      },
    );
    connectors['content'] = _is.EndpointConnector(
      name: 'content',
      endpoint: endpoints['content']!,
      methodConnectors: {
        'beginEdit': _is.MethodConnector(
          name: 'beginEdit',
          params: {
            'nodeId': _is.ParameterDescription(
              name: 'nodeId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'baseVersion': _is.ParameterDescription(
              name: 'baseVersion',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'size': _is.ParameterDescription(
              name: 'size',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'operationId': _is.ParameterDescription(
              name: 'operationId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['content'] as _iqqtuyco.ContentEndpoint).beginEdit(
                    session,
                    params['nodeId'],
                    params['baseVersion'],
                    params['size'],
                    params['operationId'],
                  ),
        ),
        'begin': _is.MethodConnector(
          name: 'begin',
          params: {
            'nodeId': _is.ParameterDescription(
              name: 'nodeId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'baseVersion': _is.ParameterDescription(
              name: 'baseVersion',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'size': _is.ParameterDescription(
              name: 'size',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['content'] as _iqqtuyco.ContentEndpoint).begin(
                    session,
                    params['nodeId'],
                    params['baseVersion'],
                    params['size'],
                  ),
        ),
        'beginMultipart': _is.MethodConnector(
          name: 'beginMultipart',
          params: {
            'nodeId': _is.ParameterDescription(
              name: 'nodeId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'baseVersion': _is.ParameterDescription(
              name: 'baseVersion',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'size': _is.ParameterDescription(
              name: 'size',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['content'] as _iqqtuyco.ContentEndpoint)
                  .beginMultipart(
                    session,
                    params['nodeId'],
                    params['baseVersion'],
                    params['size'],
                  ),
        ),
        'uploadParts': _is.MethodConnector(
          name: 'uploadParts',
          params: {
            'versionId': _is.ParameterDescription(
              name: 'versionId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'first': _is.ParameterDescription(
              name: 'first',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'count': _is.ParameterDescription(
              name: 'count',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['content'] as _iqqtuyco.ContentEndpoint)
                  .uploadParts(
                    session,
                    params['versionId'],
                    params['first'],
                    params['count'],
                  ),
        ),
        'copyParts': _is.MethodConnector(
          name: 'copyParts',
          params: {
            'versionId': _is.ParameterDescription(
              name: 'versionId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'first': _is.ParameterDescription(
              name: 'first',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'count': _is.ParameterDescription(
              name: 'count',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['content'] as _iqqtuyco.ContentEndpoint).copyParts(
                    session,
                    params['versionId'],
                    params['first'],
                    params['count'],
                  ),
        ),
        'uploadedParts': _is.MethodConnector(
          name: 'uploadedParts',
          params: {
            'versionId': _is.ParameterDescription(
              name: 'versionId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['content'] as _iqqtuyco.ContentEndpoint)
                  .uploadedParts(
                    session,
                    params['versionId'],
                  ),
        ),
        'download': _is.MethodConnector(
          name: 'download',
          params: {
            'nodeId': _is.ParameterDescription(
              name: 'nodeId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'versionId': _is.ParameterDescription(
              name: 'versionId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['content'] as _iqqtuyco.ContentEndpoint).download(
                    session,
                    params['nodeId'],
                    params['versionId'],
                  ),
        ),
        'writeChunk': _is.MethodConnector(
          name: 'writeChunk',
          params: {
            'versionId': _is.ParameterDescription(
              name: 'versionId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'index': _is.ParameterDescription(
              name: 'index',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'data': _is.ParameterDescription(
              name: 'data',
              type: _is.getType<_idt.ByteData>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['content'] as _iqqtuyco.ContentEndpoint)
                  .writeChunk(
                    session,
                    params['versionId'],
                    params['index'],
                    params['data'],
                  ),
        ),
        'finish': _is.MethodConnector(
          name: 'finish',
          params: {
            'versionId': _is.ParameterDescription(
              name: 'versionId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['content'] as _iqqtuyco.ContentEndpoint).finish(
                    session,
                    params['versionId'],
                  ),
        ),
        'read': _is.MethodConnector(
          name: 'read',
          params: {
            'nodeId': _is.ParameterDescription(
              name: 'nodeId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'versionId': _is.ParameterDescription(
              name: 'versionId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'offset': _is.ParameterDescription(
              name: 'offset',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'length': _is.ParameterDescription(
              name: 'length',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['content'] as _iqqtuyco.ContentEndpoint).read(
                    session,
                    params['nodeId'],
                    params['versionId'],
                    params['offset'],
                    params['length'],
                  ),
        ),
        'versions': _is.MethodConnector(
          name: 'versions',
          params: {
            'nodeId': _is.ParameterDescription(
              name: 'nodeId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['content'] as _iqqtuyco.ContentEndpoint).versions(
                    session,
                    params['nodeId'],
                  ),
        ),
      },
    );
    connectors['files'] = _is.EndpointConnector(
      name: 'files',
      endpoint: endpoints['files']!,
      methodConnectors: {
        'get': _is.MethodConnector(
          name: 'get',
          params: {
            'nodeId': _is.ParameterDescription(
              name: 'nodeId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['files'] as _idx8vriz.FilesEndpoint).get(
                session,
                params['nodeId'],
              ),
        ),
        'changes': _is.MethodConnector(
          name: 'changes',
          params: {
            'gardenId': _is.ParameterDescription(
              name: 'gardenId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'afterRevision': _is.ParameterDescription(
              name: 'afterRevision',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['files'] as _idx8vriz.FilesEndpoint).changes(
                    session,
                    params['gardenId'],
                    params['afterRevision'],
                  ),
        ),
        'snapshot': _is.MethodConnector(
          name: 'snapshot',
          params: {
            'gardenId': _is.ParameterDescription(
              name: 'gardenId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'afterNodeId': _is.ParameterDescription(
              name: 'afterNodeId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['files'] as _idx8vriz.FilesEndpoint).snapshot(
                    session,
                    params['gardenId'],
                    params['afterNodeId'],
                  ),
        ),
        'revision': _is.MethodConnector(
          name: 'revision',
          params: {
            'gardenId': _is.ParameterDescription(
              name: 'gardenId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['files'] as _idx8vriz.FilesEndpoint).revision(
                    session,
                    params['gardenId'],
                  ),
        ),
        'listPage': _is.MethodConnector(
          name: 'listPage',
          params: {
            'gardenId': _is.ParameterDescription(
              name: 'gardenId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'parentId': _is.ParameterDescription(
              name: 'parentId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'afterNodeId': _is.ParameterDescription(
              name: 'afterNodeId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['files'] as _idx8vriz.FilesEndpoint).listPage(
                    session,
                    params['gardenId'],
                    params['parentId'],
                    params['afterNodeId'],
                  ),
        ),
        'list': _is.MethodConnector(
          name: 'list',
          params: {
            'gardenId': _is.ParameterDescription(
              name: 'gardenId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'parentId': _is.ParameterDescription(
              name: 'parentId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['files'] as _idx8vriz.FilesEndpoint).list(
                session,
                params['gardenId'],
                params['parentId'],
              ),
        ),
        'create': _is.MethodConnector(
          name: 'create',
          params: {
            'gardenId': _is.ParameterDescription(
              name: 'gardenId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'parentId': _is.ParameterDescription(
              name: 'parentId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'kind': _is.ParameterDescription(
              name: 'kind',
              type: _is.getType<_iso8aj7z.NodeKind>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['files'] as _idx8vriz.FilesEndpoint).create(
                session,
                params['gardenId'],
                params['parentId'],
                params['name'],
                params['kind'],
              ),
        ),
        'move': _is.MethodConnector(
          name: 'move',
          params: {
            'nodeId': _is.ParameterDescription(
              name: 'nodeId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'parentId': _is.ParameterDescription(
              name: 'parentId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['files'] as _idx8vriz.FilesEndpoint).move(
                session,
                params['nodeId'],
                params['parentId'],
                params['name'],
              ),
        ),
        'delete': _is.MethodConnector(
          name: 'delete',
          params: {
            'nodeId': _is.ParameterDescription(
              name: 'nodeId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['files'] as _idx8vriz.FilesEndpoint).delete(
                session,
                params['nodeId'],
              ),
        ),
        'watch': _is.MethodStreamConnector(
          name: 'watch',
          params: {
            'gardenId': _is.ParameterDescription(
              name: 'gardenId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'afterRevision': _is.ParameterDescription(
              name: 'afterRevision',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          streamParams: {},
          returnType: _is.MethodStreamReturnType.streamType,
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['files'] as _idx8vriz.FilesEndpoint).watch(
                session,
                params['gardenId'],
                params['afterRevision'],
              ),
        ),
      },
    );
    connectors['filesystem'] = _is.EndpointConnector(
      name: 'filesystem',
      endpoint: endpoints['filesystem']!,
      methodConnectors: {
        'mutate': _is.MethodConnector(
          name: 'mutate',
          params: {
            'gardenId': _is.ParameterDescription(
              name: 'gardenId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'request': _is.ParameterDescription(
              name: 'request',
              type: _is.getType<_ia306jky.FilesystemRequest>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['filesystem'] as _im12bomv.FilesystemEndpoint)
                      .mutate(
                        session,
                        params['gardenId'],
                        params['request'],
                      ),
        ),
      },
    );
    connectors['garden'] = _is.EndpointConnector(
      name: 'garden',
      endpoint: endpoints['garden']!,
      methodConnectors: {
        'account': _is.MethodConnector(
          name: 'account',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['garden'] as _isd11de7.GardenEndpoint)
                  .account(session),
        ),
        'finderSession': _is.MethodConnector(
          name: 'finderSession',
          params: {
            'gardenId': _is.ParameterDescription(
              name: 'gardenId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['garden'] as _isd11de7.GardenEndpoint)
                  .finderSession(
                    session,
                    params['gardenId'],
                  ),
        ),
        'revokeFinderSessions': _is.MethodConnector(
          name: 'revokeFinderSessions',
          params: {
            'tokenIds': _is.ParameterDescription(
              name: 'tokenIds',
              type: _is.getType<List<String>>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['garden'] as _isd11de7.GardenEndpoint)
                  .revokeFinderSessions(
                    session,
                    params['tokenIds'],
                  ),
        ),
        'list': _is.MethodConnector(
          name: 'list',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['garden'] as _isd11de7.GardenEndpoint).list(
                session,
              ),
        ),
        'create': _is.MethodConnector(
          name: 'create',
          params: {
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['garden'] as _isd11de7.GardenEndpoint).create(
                    session,
                    params['name'],
                  ),
        ),
        'invite': _is.MethodConnector(
          name: 'invite',
          params: {
            'gardenId': _is.ParameterDescription(
              name: 'gardenId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['garden'] as _isd11de7.GardenEndpoint).invite(
                    session,
                    params['gardenId'],
                  ),
        ),
        'join': _is.MethodConnector(
          name: 'join',
          params: {
            'invitationCode': _is.ParameterDescription(
              name: 'invitationCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['garden'] as _isd11de7.GardenEndpoint).join(
                session,
                params['invitationCode'],
              ),
        ),
        'connect': _is.MethodConnector(
          name: 'connect',
          params: {
            'gardenId': _is.ParameterDescription(
              name: 'gardenId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['garden'] as _isd11de7.GardenEndpoint).connect(
                    session,
                    params['gardenId'],
                  ),
        ),
        'delete': _is.MethodConnector(
          name: 'delete',
          params: {
            'gardenId': _is.ParameterDescription(
              name: 'gardenId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['garden'] as _isd11de7.GardenEndpoint).delete(
                    session,
                    params['gardenId'],
                  ),
        ),
      },
    );
    connectors['greeting'] = _is.EndpointConnector(
      name: 'greeting',
      endpoint: endpoints['greeting']!,
      methodConnectors: {
        'hello': _is.MethodConnector(
          name: 'hello',
          params: {
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['greeting'] as _il624ik7.GreetingEndpoint).hello(
                    session,
                    params['name'],
                  ),
        ),
      },
    );
    modules['serverpod_auth_idp'] = _iais.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _iacs.Endpoints()
      ..initializeEndpoints(server);
  }

  @override
  _is.FutureCallDispatch? get futureCalls {
    return _id1va6nu.FutureCalls();
  }
}
