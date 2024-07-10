import Foundation

import ChimeKit

@MainActor
public final class ElixirExtension {
	private let lspService: LSPService

	public init(host: any HostProtocol) {
		self.lspService = LSPService(host: host,
									 executableName: "elixir-ls")
	}
}

extension ElixirExtension: ExtensionProtocol {
	public var configuration: ExtensionConfiguration {
		ExtensionConfiguration(contentFilter: [.uti(.elixirSource)])
	}

	public var applicationService: some ApplicationService {
		return lspService
	}
}
