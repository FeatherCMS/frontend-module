//
//  SiteSettingsForm.swift
//  FrontendModule
//
//  Created by Tibor Bodecs on 2020. 11. 19..
//

import FeatherCore

final class FrontendSettingsForm: Form {

    var title = FormField<String>(key: "title").required().length(max: 250)
    var excerpt = FormField<String>(key: "excerpt")
    var noindex = FormField<Bool>(key: "noindex")
    var primaryColor = FormField<String>(key: "primaryColor")
    var secondaryColor = FormField<String>(key: "secondaryColor")
    var fontFamily = FormField<String>(key: "fontFamily")
    var fontSize = FormField<String>(key: "fontSize")
    var locale = SelectionFormField<String>(key: "locale")
    var timezone = SelectionFormField<String>(key: "timezone")
    var filters = ArraySelectionFormField<String>(key: "filters")
    var css = FormField<String>(key: "css")
    var js = FormField<String>(key: "js")
    var footer = FormField<String>(key: "footer")
    var footerBottom = FormField<String>(key: "footerBottom")
    var copy = FormField<String>(key: "copy")
    var copyPrefix = FormField<String>(key: "copyPrefix")
    var image = FileFormField(key: "image")
    var notification: String?

    var fields: [FormFieldRepresentable] {
        [title, excerpt, noindex, primaryColor, secondaryColor, fontFamily, fontSize, locale, timezone, filters, css, js, footer, footerBottom, copy, copyPrefix, image]
    }

    init() {}

    // MARK: - private helpers
    
    private func settingsKey(for key: String) -> String { "frontend.site." + key }

    private func load(key: String, keyPath: ReferenceWritableKeyPath<FrontendSettingsForm, FormField<String>>, req: Request) -> EventLoopFuture<Void> {
        req.variable(settingsKey(for: key)).map { [unowned self] in self[keyPath: keyPath].value = $0 }
    }

    private func save(key: String, value: String?, req: Request) -> EventLoopFuture<Void> {
        req.setVariable(settingsKey(for: key), value: value)
    }

    // MARK: - form api
    
    func initialize(req: Request) -> EventLoopFuture<Void> {
        locale.value = Application.Config.locale.identifier
        locale.options = FormFieldOption.locales

        timezone.value = Application.Config.timezone.identifier
        timezone.options = FormFieldOption.gmtTimezones
                
        let contentFilters: [[ContentFilter]] = req.invokeAll("content-filters")
        filters.options = contentFilters.flatMap { $0 }.map(\.formFieldOption)

        return req.eventLoop.flatten([
            req.variable(settingsKey(for: "logo"))
                .map { [unowned self] in image.value.originalKey = $0?.emptyToNil },

            req.variable(settingsKey(for: "filters"))
                .map { [unowned self] in filters.values = $0?.split(separator: ",").map { String($0) } ?? [] },
            
            req.variable(settingsKey(for: "noindex"))
                .map { [unowned self] in noindex.value = Bool($0 ?? "false") ?? false },

            load(key: "title", keyPath: \.title, req: req),
            load(key: "excerpt", keyPath: \.excerpt, req: req),

            load(key: "color.primary", keyPath: \.primaryColor, req: req),
            load(key: "color.secondary", keyPath: \.secondaryColor, req: req),
            load(key: "font.family", keyPath: \.fontFamily, req: req),
            load(key: "font.size", keyPath: \.fontSize, req: req),
            
            load(key: "css", keyPath: \.css, req: req),
            load(key: "js", keyPath: \.js, req: req),
            load(key: "footer", keyPath: \.footer, req: req),
            load(key: "footer.bottom", keyPath: \.footerBottom, req: req),
            load(key: "copy", keyPath: \.copy, req: req),
            load(key: "copy.prefix", keyPath: \.copyPrefix, req: req),
        ])
    }

    func validate(req: Request) -> EventLoopFuture<Bool> {
        guard validateFields() else {
            notification = "Invalid form data"
            return req.eventLoop.future(false)
        }
        return req.eventLoop.future(true)
    }
    
    func processAfterFields(req: Request) -> EventLoopFuture<Void> {
        image.uploadTemporaryFile(req: req)
    }

    func save(req: Request) -> EventLoopFuture<Void> {
        Application.Config.set("site.locale", value: locale.value!)
        Application.Config.set("site.timezone", value: timezone.value!)
        
        return req.eventLoop.flatten([
            image.save(to: FrontendModule.path, req: req)
                .flatMap { [unowned self] key in
                    if let key = key {
                        return save(key: "logo", value: key, req: req)
                    }
                    return req.eventLoop.future()
                },
            
            save(key: "filters", value: filters.values.joined(separator: ","), req: req),
            save(key: "title", value: title.value, req: req),
            save(key: "excerpt", value: excerpt.value, req: req),
            save(key: "noindex", value: String(noindex.value ?? false), req: req),
            save(key: "color.primary", value: primaryColor.value, req: req),
            save(key: "color.secondary", value: secondaryColor.value, req: req),
            save(key: "font.family", value: fontFamily.value, req: req),
            save(key: "font.size", value: fontSize.value, req: req),
            save(key: "css", value: css.value, req: req),
            save(key: "js", value: js.value, req: req),
            save(key: "footer", value: footer.value, req: req),
            save(key: "footer.bottom", value: footerBottom.value, req: req),
            save(key: "copy", value: copy.value, req: req),
            save(key: "copy.prefix", value: copyPrefix.value, req: req),
        ])
        .map { [unowned self] in notification = "Settings saved" }
    }
}
