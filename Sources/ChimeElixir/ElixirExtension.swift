import Foundation
import os.log

import ChimeKit
import ProcessServiceClient

public final class ElixirExtension {
	let host: any HostProtocol
	private let lspService: LSPService
	private let logger: Logger

	public init(host: any HostProtocol, processHostServiceName: String) {
		self.host = host
		let logger = Logger(subsystem: "com.chimehq.ChimeElixir", category: "ElixirExtension")
		self.logger = logger

		let filter = LSPService.contextFilter(for: [.elixirSource])
		let paramProvider = { try await ElixirExtension.provideParams(logger: logger, processHostService: processHostServiceName) }

		self.lspService = LSPService(host: host,
									 contextFilter: filter,
									 executionParamsProvider: paramProvider,
									 processHostServiceName: processHostServiceName)
	}
}

extension ElixirExtension {
	private static func provideParams(logger: Logger, processHostService: String) async throws -> Process.ExecutionParameters {
		let userEnv = try await HostedProcess.userEnvironment(with: processHostService)

		let whichParams = Process.ExecutionParameters(path: "/usr/bin/which", arguments: ["elixir-ls"], environment: userEnv)

		let data = try await HostedProcess(named: processHostService, parameters: whichParams).runAndReadStdout()

		guard let output = String(data: data, encoding: .utf8) else {
			throw LSPServiceError.serverNotFound
		}

		if output.isEmpty {
			throw LSPServiceError.serverNotFound
		}

		let path = output.trimmingCharacters(in: .whitespacesAndNewlines)

		logger.info("tool found: \(path, privacy: .public)")

		return .init(path: path, environment: userEnv)
	}
}

extension ElixirExtension: ExtensionProtocol {
	public func didOpenProject(with context: ProjectContext) async throws {
		try await lspService.didOpenProject(with: context)
	}

	public func willCloseProject(with context: ProjectContext) async throws {
		try await lspService.willCloseProject(with: context)
	}

	public func symbolService(for context: ProjectContext) async throws -> SymbolQueryService? {
		return try await lspService.symbolService(for: context)
	}

	public func didOpenDocument(with context: DocumentContext) async throws -> URL? {
		return try await lspService.didOpenDocument(with: context)
	}

	public func didChangeDocumentContext(from oldContext: DocumentContext, to newContext: DocumentContext) async throws {
		return try await lspService.didChangeDocumentContext(from: oldContext, to: newContext)
	}

	public func willCloseDocument(with context: DocumentContext) async throws {
		return try await lspService.willCloseDocument(with: context)
	}

	public func documentService(for context: DocumentContext) async throws -> DocumentService? {
		return try await lspService.documentService(for: context)
	}
}
