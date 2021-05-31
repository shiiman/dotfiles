package mg

var (
	actionCreators = map[string]actionCreator{
		"QueryCompletions": func() Action { return QueryCompletions{} },
		"QueryIssues":      func() Action { return QueryIssues{} },
		"QueryTooltips":    func() Action { return QueryTooltips{} },
		"Restart":          func() Action { return Restart{} },
		"Shutdown":         func() Action { return Shutdown{} },
		"ViewActivated":    func() Action { return ViewActivated{} },
		"ViewClosed":       func() Action { return ViewClosed{} },
		"ViewFmt":          func() Action { return ViewFmt{} },
		"ViewLoaded":       func() Action { return ViewLoaded{} },
		"ViewModified":     func() Action { return ViewModified{} },
		"ViewPosChanged":   func() Action { return ViewPosChanged{} },
		"ViewPreSave":      func() Action { return ViewPreSave{} },
		"ViewSaved":        func() Action { return ViewSaved{} },
	}
)

type actionCreator func() Action

type ActionType struct{}

func (act ActionType) Type() ActionType {
	return act
}

type Action interface {
	Type() ActionType
}

var Render Action = nil

// Started is dispatched to indicate the start of IPC communication.
// It's the first action that is dispatched.
// Reducers may do lazy initialization during this action.
type Started struct{ ActionType }

type QueryCompletions struct{ ActionType }

type QueryIssues struct{ ActionType }

type QueryTooltips struct{ ActionType }

type Restart struct{ ActionType }

type Shutdown struct{ ActionType }

type ViewActivated struct{ ActionType }

type ViewModified struct{ ActionType }

type ViewPosChanged struct{ ActionType }

type ViewFmt struct{ ActionType }

type ViewPreSave struct{ ActionType }

type ViewSaved struct{ ActionType }

type ViewLoaded struct{ ActionType }

type ViewClosed struct{ ActionType }
